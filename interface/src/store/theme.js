import { Subject } from 'rxjs';

const subject = new Subject();

const initialState = {
  paletteType: 'dark',
};

let state = initialState;

const themeStore = {
  init: () => subject.next(state),
  subscribe: setState => subject.subscribe(setState),
  togglePaletteType: () => {
    state = {
      ...state,
      paletteType: state.paletteType === 'dark' ? 'light' : 'dark',
    };
    subject.next(state);
  },
  initialState,
};

export default themeStore;
