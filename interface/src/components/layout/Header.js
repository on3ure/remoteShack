import React from 'react';
import { withStyles } from '@material-ui/core/styles';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Drawer from '@material-ui/core/Drawer';
import classNames from 'classnames';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import IconButton from '@material-ui/core/IconButton';
import Divider from '@material-ui/core/Divider';
import { Link } from 'react-router-dom';
import MenuIcon from '@material-ui/icons/Menu';
import CloseIcon from '@material-ui/icons/Close';
import Collapse from '@material-ui/core/Collapse';
import ExpandLess from '@material-ui/icons/ExpandLess';
import ExpandMore from '@material-ui/icons/ExpandMore';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';

const drawerWidth = 240;

const defaultHeaderStyles = theme => ({
  appBar: {
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.leavingScreen,
    }),
  },
  appBarShift: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
  menuButton: {
    marginLeft: 12,
    marginRight: 20,
  },
  toolbarTitle: {
    flex: 1,
    width: 200,
  },
  hide: {
    display: 'none',
  },
  drawer: {
    width: drawerWidth,
    flexShrink: 0,
  },
  drawerHeader: {
    textAlign: 'center',
    padding: 20,
  },
  drawerPaper: {
    width: drawerWidth,
  },
  logo: {
    paddingTop: 10,
    width: 200,
  },
  nested: {
    paddingLeft: theme.spacing(4),
  },
});

class Header extends React.Component {
  state = {
    subNavs: [],
  };

  handleClick(item, parent = null) {
    let { subNavs } = this.state;

    if (!subNavs[item]) {
      subNavs = [];
      if (parent) {
        subNavs[parent] = true;
      }
      subNavs[item] = true;
    } else {
      delete subNavs[item];
    }

    this.setState({ subNavs });
  }

  handler(children, level = 0, parent = null) {
    const { subNavs } = this.state;
    if (!children) {
      return;
    }
    return children.map(subOption => {
      if (!subOption.children) {
        return (
          <div key={subOption.name} style={{ paddingLeft: level + 'px' }}>
            <Link to={subOption.path} style={{ textDecoration: 'none' }}>
              <ListItem button key={subOption.name}>
                <ListItemText primary={subOption.name} />
              </ListItem>
            </Link>
          </div>
        );
      }

      return (
        <div key={subOption.name} style={{ paddingLeft: level + 'px' }}>
          <ListItem button onClick={() => this.handleClick(subOption.name, parent)}>
            <ListItemText primary={subOption.name} />
            {subNavs[subOption.name] ? <ExpandLess /> : <ExpandMore />}
          </ListItem>
          <Collapse in={subNavs[subOption.name]} timeout="auto" unmountOnExit>
            {this.handler(subOption.children, level + 15, subOption.name)}
          </Collapse>
        </div>
      );
    });
  }

  render() {
    const {
      classes,
      drawerOpen,
      toggleDrawer,
      navItems,
      drawerTitle,
      paletteType,
      togglePaletteType,
    } = this.props;
    return [
      <AppBar
        position="fixed"
        className={classNames(classes.appBar, {
          [classes.appBarShift]: drawerOpen,
        })}
        key="appBar">
        <Toolbar disableGutters={true}>
          <IconButton
            color="inherit"
            aria-label="Open drawer"
            onClick={toggleDrawer}
            className={classNames(classes.menuButton)}>
            {drawerOpen ? <CloseIcon /> : <MenuIcon />}
          </IconButton>
          <Typography variant="h6" color="inherit" noWrap className={classes.toolbarTitle}>
            ADMIN
          </Typography>
          <div style={{ float: 'right', marginRight: 20 }}>
            <FormControlLabel
              control={
                <Switch
                  checked={paletteType === 'dark' ? true : false}
                  onChange={togglePaletteType}
                  name="darkmode"
                  color="secondary"
                />
              }
              label="Dark mode"
            />
          </div>
        </Toolbar>
      </AppBar>,
      <Drawer
        className={classes.drawer}
        variant="persistent"
        anchor="left"
        open={drawerOpen}
        classes={{
          paper: classes.drawerPaper,
        }}
        key="dr">
        <div>
          <div className={classes.drawerHeader}>
            <Typography variant="h5" noWrap>
              {drawerTitle}
            </Typography>
          </div>
          <Divider />
          <List>{this.handler(navItems.data)}</List>
        </div>
      </Drawer>,
    ];
  }
}

export default withStyles(defaultHeaderStyles)(Header);
