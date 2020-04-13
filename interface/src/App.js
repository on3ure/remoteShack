import React, { useState, useLayoutEffect } from 'react';
import { ThemeProvider } from '@material-ui/styles';
import { CssBaseline, createMuiTheme, makeStyles } from '@material-ui/core';

import Header from 'components/layout/Header';
import Footer from 'components/layout/Footer';

import themeStore from 'store/theme';
import dataStore from 'store/data';

const useStyles = makeStyles({});

const App = () => {
  const [themeConfig, setThemeConfig] = useState(themeStore.initialState);
  const [switches, setSwitches] = useState(dataStore.initialState);
  const [drawerOpen, setDrawerOpen] = useState(false);

  useLayoutEffect(() => {
    themeStore.subscribe(setThemeConfig);
    themeStore.init();
    dataStore.subscribe(setSwitches);
    dataStore.subscribeInitialData();
    dataStore.subscribeWs();
    dataStore.init();
  }, []);

  const classes = useStyles();

  const theme = createMuiTheme({
    palette: {
      type: themeConfig.paletteType,
    },
  });

  const drawerTitle = 'Hoi';
  const navItems = {};

  const toggleDrawerOpen = () => {
    setDrawerOpen(!drawerOpen);
  };

  const togglePaletteType = () => {
    themeStore.togglePaletteType();
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
        <main></main>
        <Footer drawerOpen={drawerOpen} />
      </div>
    </ThemeProvider>
  );
};

export default App;
