import React, { useState, useLayoutEffect } from 'react';
import { ThemeProvider } from '@material-ui/styles';
import { CssBaseline, createMuiTheme, makeStyles } from '@material-ui/core';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import classNames from 'classnames';

import Header from 'components/layout/Header';
import Footer from 'components/layout/Footer';

import themeStore from 'store/theme';
import dataStore from 'store/data';

const App = () => {
  const [themeConfig, setThemeConfig] = useState(themeStore.initialState);
  const [data, setData] = useState(dataStore.initialState);
  const [drawerOpen, setDrawerOpen] = useState(false);

  useLayoutEffect(() => {
    themeStore.subscribe(setThemeConfig);
    themeStore.init();
    dataStore.subscribe(setData);
    dataStore.subscribeInitialData();
    dataStore.subscribeWs();
    dataStore.init();
  }, []);

  const theme = createMuiTheme({
    palette: {
      type: themeConfig.paletteType,
    },
  });

  const useStyles = makeStyles({
    root: {
      display: 'flex',
    },
    content: {
      flexGrow: 1,
      padding: theme.spacing(3),
      transition: theme.transitions.create('margin', {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.leavingScreen,
      }),
      marginLeft: -240,
    },
    contentShift: {
      transition: theme.transitions.create('margin', {
        easing: theme.transitions.easing.easeOut,
        duration: theme.transitions.duration.enteringScreen,
      }),
      marginLeft: 0,
    },
    drawerHeader: {
      display: 'flex',
      alignItems: 'center',
      padding: '0 8px',
      ...theme.mixins.toolbar,
      justifyContent: 'flex-end',
    },
  });

  const classes = useStyles();

  const drawerTitle = 'Hoi';
  const navItems = {};

  const toggleDrawerOpen = () => {
    setDrawerOpen(!drawerOpen);
  };

  const togglePaletteType = () => {
    themeStore.togglePaletteType();
  };

  const toggleSwitch = event => {
    dataStore.toggleSwitch(event.currentTarget.name);
  };

  return (
    <ThemeProvider theme={theme}>
      <div className={classes.root}>
        <CssBaseline />
        <Header
          toggleDrawer={toggleDrawerOpen}
          drawerOpen={drawerOpen}
          navItems={navItems}
          drawerTitle={drawerTitle}
          paletteType={themeConfig.paletteType}
          togglePaletteType={togglePaletteType}
        />
        <main
          className={classNames(classes.content, {
            [classes.contentShift]: drawerOpen,
          })}>
          <div className={classes.drawerHeader} id="pusher" />
          {(data.switches && Object.keys(data.switches)).length > 0 &&
            Object.keys(data.switches).map(index => (
              <FormControlLabel
                control={
                  <Switch
                    checked={data.switches[index] === 'on' ? true : false}
                    onChange={toggleSwitch}
                    name={index}
                    color="secondary"
                  />
                }
                key={index}
                label={index}
              />
            ))}
        </main>
        <Footer drawerOpen={drawerOpen} />
      </div>
    </ThemeProvider>
  );
};

export default App;
