import React from 'react';
import { TableRow, TableCell, Typography, Checkbox } from '@material-ui/core';
import IconButton from '@material-ui/core/IconButton';
import EditOutlinedIcon from '@material-ui/icons/EditOutlined';
import DeleteOutlinedIcon from '@material-ui/icons/DeleteOutlined';
import Box from '@material-ui/core/Box';

const weight = {
  fontWeight: 600
};

export default class WaitListTableItem extends React.Component {
  constructor(props) {
    super(props);
    this.handleInterval = this.handleInterval.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleEdit = this.handleEdit.bind(this);
    this.state = {
      waitTime: 0
    };
  }

  getWaitTime(SQLTime, type = 'long') {
    const SQLMinutes = this.parseSQLTime(SQLTime);
    const d = new Date();
    const currentMinutes = (d.getHours() * 60) + parseInt(d.getMinutes(), 10);
    const waitTotal = currentMinutes - SQLMinutes;
    const waitMinutes = waitTotal % 60;
    const waitHours = (waitTotal - waitMinutes) / 60;
    let waitTime = '';
    if (type === 'long') {
      waitTime = `${waitHours} hours ${waitMinutes} minutes`;
    } else {
      waitTime = `${waitHours}:${waitMinutes.toString().padStart(2, '0')}`;
    }
    return waitTime;
  }

  parseSQLTime(SQLTime) {
    const timeArray = SQLTime.split(':');
    const [hour, minute] = timeArray;
    const totalMinutes = (hour * 60) + parseInt(minute, 10);
    return totalMinutes;
  }

  handleInterval() {
    const waitTime = this.getWaitTime(this.props.root.time);
    this.setState({ waitTime: waitTime });
  }

  componentDidMount() {
    this.handleInterval();
    this.interval = setInterval(this.handleInterval, 60000);
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  computeStyle() {
    if (this.props.root.isSeated) {
      const style = {
        background: '#3C3C3C',
        color: 'white'
      };
      return style;
    } else {
      return {};
    }
  }

  handleChange(e) {
    const paramsObj = {
      waitId: this.props.root.waitId,
      isSeated: this.props.root.isSeated
    };
    this.props.seatCustomer(paramsObj);
  }

  handleDelete(e) {
    const waitId = parseInt(e.currentTarget.id, 10);
    if (!waitId) {
      return;
    }
    this.props.deleteCustomer(waitId);
  }

  handleEdit(e) {
    const waitId = parseInt(e.currentTarget.id, 10);
    if (!waitId) {
      return;
    }
    let { name, partySize, comment } = this.props.root;
    if (comment === null) {
      comment = '';
    }
    const paramsObj = {
      waitId: waitId,
      name: name,
      partySize: partySize,
      comment: comment
    };
    this.props.editCustomer(paramsObj);
  }

  render() {
    const props = this.props.root;
    let isChecked;
    let waitTime;
    if (props.isSeated) {
      waitTime = 'Seated';
      isChecked = true;
    } else {
      waitTime = this.state.waitTime;
      isChecked = false;
    }
    const style = this.computeStyle();

    return (
      <TableRow hover={true}>
        <TableCell style={style}>
          <Checkbox
            color="default"
            onChange={this.handleChange}
            checked={isChecked}
          />
        </TableCell>
        <TableCell style={style} align="center">
          <Typography style={weight}>{props.partySize}</Typography>
        </TableCell>
        <TableCell style={style} align="center">{props.name}</TableCell>
        <TableCell style={style} align="center">{waitTime}</TableCell>
        <TableCell style={style} align="center">{props.comment}</TableCell>
        <TableCell style={style} align="center">
          <Box display="flex" justifyContent="center">
            <IconButton onClick={this.handleDelete} id={props.waitId}>
              <DeleteOutlinedIcon />
            </IconButton>
            <IconButton onClick={this.handleEdit} id={props.waitId}>
              <EditOutlinedIcon />
            </IconButton>
          </Box>
        </TableCell>
      </TableRow>
    );
  }
}
