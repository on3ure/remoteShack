import React from 'react';
import { withStyles } from '@material-ui/core/styles';
import Typography from '@material-ui/core/Typography';

const defaultFooterStyles = theme => ({
  footer: {
    display: 'block',
    background: 'black',
    position: 'fixed',
    bottom: 0,
    width: '100%',
  },
  footerText: {
    color: 'white',
    fontSize: 14,
    padding: 24,
    transition: theme.transitions.create(['padding', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
});

class Footer extends React.Component {
  render() {
    const { classes, drawerOpen } = this.props;
    const date = new Date();

    return (
      <footer className={classes.footer}>
        <Typography
          variant="h6"
          className={classes.footerText}
          gutterBottom
          style={drawerOpen ? { paddingLeft: 260 } : {}}>
          © {date.getFullYear()} Admin
        </Typography>
      </footer>
    );
  }
}

export default withStyles(defaultFooterStyles)(Footer);
