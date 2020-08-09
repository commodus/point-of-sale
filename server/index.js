require('dotenv/config');
const express = require('express');
const multer = require('multer');
const db = require('./database');
const ClientError = require('./client-error');
const staticMiddleware = require('./static-middleware');
const sessionMiddleware = require('./session-middleware');

const app = express();

app.use(staticMiddleware);
app.use(sessionMiddleware);

app.use(express.json());

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'server/public/images/');
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname);
  }
});
const upload = multer({ storage: storage });

function checkValidity(num) {
  const intNum = parseInt(num);
  if (isNaN(intNum) || intNum < 0) {
    return false;
  } else {
    return true;
  }
}

function getDbParam(orderId, items) {
  const paramDb = [];
  const order = [];
  const item = [];
  const quantity = [];
  const discount = [];
  const time = [];

  items.forEach(element => {
    order.push(orderId);
    item.push(element[0]);
    quantity.push(element[1]);
    discount.push(0);
    time.push('NOW()');
  });

  paramDb.push(order, item, quantity, discount, time);
  return paramDb;
}

app.get('/api/restaurant', (req, res, next) => {
  const sql = `
    select *
      from "tables"
  `;
  db.query(sql)
    .then(result => {
      res.status(200).json(result.rows);
    })
    .catch(error => {
      next(error);
    });
});

app.get('/api/menus', (req, res, next) => {
  const sql = `
    select *
      from "menus"
  `;

  db.query(sql)
    .then(result => {
      res.status(200).json(result.rows);
    })
    .catch(err => next(err));
});

app.post('/api/menus', upload.single('image'), (req, res) => {
  const item = req.body.item;
  let cost = req.body.cost;
  let salePrice = req.body.salePrice;

  if (!item || !cost || !salePrice) {
    return res.status(400).json({ error: 'Sorry, missing information. Check input data again.' });
  }

  cost = parseFloat(cost).toFixed(2);
  salePrice = parseFloat(salePrice).toFixed(2);
  const url = req.file ? '/images/' + req.file.filename : null;
  const paramDb = [item, cost, salePrice, url];
  const sql = `
      insert into "menus" ("item", "cost", "salePrice", "imageUrl")
           values ($1, $2, $3, $4)
        returning *
    `;

  db.query(sql, paramDb)
    .then(result => {
      res.status(201).json(result.rows[0]);
    })
    .catch(() => res.status(500).json({ error: 'An unexpected error occured.' }));
});

app.put('/api/menus/:itemId', (req, res, next) => {
  const itemId = req.params.itemId;
  const item = req.body.item;
  let cost = req.body.cost;
  let salePrice = req.body.salePrice;

  if (!checkValidity(itemId) || !item || !cost || !salePrice) {
    next(new ClientError('Sorry, your requested information is invalid.', 400));
  }

  cost = parseFloat(cost).toFixed(2);
  salePrice = parseFloat(salePrice).toFixed(2);
  const url = req.body.image ? '/images/' + req.body.image : null;

  const paramDb = [item, cost, salePrice, url, itemId];
  const sql = `
    update "menus"
       set "item" = $1,
           "cost" = $2,
           "salePrice" = $3,
           "imageUrl" = $4
     where "itemId" = $5
           returning *
   `;

  db.query(sql, paramDb)
    .then(result => {
      if (result.rows[0] === undefined) {
        next(new ClientError('Requested itemId may not exist in the database. Check your data agin.', 404));
      } else {
        res.status(200).json(result.rows[0]);
      }
    })
    .catch(() => res.status(500).json({ error: 'Database query failed' }));
});

app.delete('/api/menus/:itemId', (req, res, next) => {
  if (!checkValidity(req.params.itemId)) {
    next(new ClientError('Sorry, your requested id is invalid.', 400));
  }
  const itemId = parseInt(req.params.itemId);
  const paramDb = [itemId];
  const sql = `
    delete from "menus"
          where "itemId" = $1
      returning *
   `;

  db.query(sql, paramDb)
    .then(result => {
      if (result.rows[0] === undefined) {
        next(new ClientError('Requested itemId may not exist in the database. Check your data agin.', 404));
      } else {
        res.status(204).end();
      }
    })
    .catch(err => next(err));
});

app.get('/api/checks', (req, res, next) => {
  const sql = `
    select * from "checks"
      where "isPaid" = false
    `;
  db.query(sql)
    .then(result => {
      res.status(200).json(result.rows);
    })
    .catch(error => {
      next(error);
    });
});

app.post('/api/orders/', (req, res, next) => {
  if (!checkValidity(req.body.tableId) || req.body.items.length === 0) {
    next(new ClientError('Sorry, your order information is incomplete.', 400));
  }

  const paramDb = [parseInt(req.body.tableId), 'NOW()'];
  const sql = `
      insert into "orders" ("tableId", "orderedAt")
          values ($1, $2)
        returning *
    `;

  db.query(sql, paramDb)
    .then(result => {
      const orderId = result.rows[0].orderId;
      const paramDb = getDbParam(orderId, req.body.items);
      const sql = `
          insert into "orderItems" ("orderId", "itemId", "quantity", "discount", "createdAt")
        select * from UNNEST ($1::int[], $2::int[], $3::int[], $4::int[], $5::timestamp[])
            returning "orderItemId"
      `;

      return db.query(sql, paramDb)
        .then(result2 => {
          const orderItemIds = result2.rows;
          return { orderId, orderItemIds };
        });
    })
    .then(result => {
      res.status(201).json(result);
    })
    .catch(err => next(err));
});

app.get('/api/waitlist', (req, res, next) => {
  const sql = `select * from "waitLists"
  order by  "isSeated" asc, "time" asc;`;
  db.query(sql)
    .then(result => {
      res.status(200).json(result.rows);
    })
    .catch(err => next(err));
});

app.get('/api/checks/:checkId', (req, res, next) => {
  const { checkId } = req.params;
  const sql = `
  select "m".* from "checks" as "c"
  join "checkOrders" as "co" on "co"."checkId" = "c"."checkId"
  join "orders" as "o" on "o"."orderId" = "co"."orderId"
  join "orderItems" as "oi" on "oi"."orderId" = "o"."orderId"
  join "menus" as "m" on "m"."itemId" = "oi"."itemId"
  where "c"."checkId" = $1;
  `;
  const params = [checkId];
  db.query(sql, params)
    .then(result => {
      res.status(200).json(result.rows);
    })
    .catch(err => next(err));
});

app.post('/api/waitlist', (req, res, next) => {
  const partySize = parseInt(req.body.partySize, 10);
  if (!partySize || !req.body.name) {
    next(new ClientError('missing partySize or name', 400));
  }
  let comment;
  if (req.body.comment) {
    comment = req.body.comment;
  } else {
    comment = null;
  }
  const sql = `insert into "waitLists" ("name", "partySize", "comment", "time")
    values($1, $2, $3, now())
    returning *`;
  const params = [req.body.name, partySize, comment];
  db.query(sql, params)
    .then(result => {
      res.status(200).json(result.rows[0]);
    })
    .catch(err => next(err));
});

app.patch('/api/waitlist/:waitId', (req, res, next) => {
  const waitId = parseInt(req.params.waitId, 10);
  if (!waitId) {
    next(new ClientError('waitId is invalid: not a number', 400));
    return;
  }
  const sql = `
  update "waitLists"
  set "isSeated" = true
  where "waitId" = $1
  returning *
  `;
  const params = [waitId];
  db.query(sql, params)
    .then(result => {
      const updated = result.rows[0];
      if (!updated) {
        next(new ClientError('waitId is invalid: number not in DB', 404));
        return;
      }
      res.status(200).json(updated);
    })
    .catch(err => next(err));
});

app.use('/api', (req, res, next) => {
  next(new ClientError(`cannot ${req.method} ${req.originalUrl}`, 404));
});

app.use((err, req, res, next) => {
  if (err instanceof ClientError) {
    res.status(err.status).json({ error: err.message });
  } else {
    console.error(err);
    res.status(500).json({
      error: 'an unexpected error occurred'
    });
  }
});

app.listen(process.env.PORT, () => {
  // eslint-disable-next-line no-console
  console.log('Listening on port', process.env.PORT);
});
