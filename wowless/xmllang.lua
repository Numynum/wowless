return {
  absdimension = {
    fields = {
      x = {
        source = 'attribute',
        type = 'number',
      },
      y = {
        source = 'attribute',
        type = 'number',
      },
    },
  },
  absinset = {
    attributes = {
      bottom = {
        type = 'number',
      },
      left = {
        type = 'number',
      },
      right = {
        type = 'number',
      },
      top = {
        type = 'number',
      },
    },
  },
  absvalue = {
    attributes = {
      val = {
        type = 'number',
      },
    },
  },
  actor = {
    attributes = {
      mixin = {
        type = 'stringlist',
      },
      name = {
        type = 'string',
      },
      virtual = {
        type = 'bool',
      },
    },
    children = {
      scripts = true,
    },
  },
  alpha = {
    attributes = {
      fromalpha = {
        type = 'number',
      },
      toalpha = {
        type = 'number',
      },
    },
    extends = 'animation',
  },
  anchor = {
    fields = {
      offset = {
        source = 'child',
      },
      point = {
        source = 'attribute',
        type = 'string',
      },
      relativekey = {
        source = 'attribute',
        type = 'string',
      },
      relativepoint = {
        source = 'attribute',
        type = 'string',
      },
      relativeto = {
        source = 'attribute',
        type = 'string',
      },
      x = {
        source = 'attribute',
        type = 'number',
      },
      y = {
        source = 'attribute',
        type = 'number',
      },
    },
  },
  anchors = {
    fields = {
      anchor = {
        repeated = true,
        source = 'child',
      },
    },
  },
  animationgroup = {
    attributes = {
      looping = {
        type = 'string',
      },
      settofinalalpha = {
        type = 'bool',
      },
    },
    children = {
      animation = true,
      scripts = true,
    },
    extends = 'layoutframe',
  },
  animation = {
    attributes = {
      childkey = {
        type = 'string',
      },
      duration = {
        type = 'number',
      },
      enddelay = {
        type = 'number',
      },
      order = {
        type = 'number',
      },
      parentkey = {
        type = 'string',
      },
      smoothing = {
        type = 'string',
      },
      startdelay = {
        type = 'number',
      },
      target = {
        type = 'string',
      },
    },
    children = {
      keyvalues = true,
      scripts = true,
    },
  },
  animations = {
    fields = {
      groups = {
        child = 'animationgroup',
        repeated = true,
        required = true,
        source = 'child',
      },
    },
  },
  attribute = {
    fields = {
      luatype = {
        attribute = 'type',
        source = 'attribute',
        type = 'string',
      },
      name = {
        source = 'attribute',
        type = 'string',
      },
      value = {
        source = 'attribute',
        type = 'string',
      },
    },
  },
  attributes = {
    fields = {
      entries = {
        child = 'attribute',
        repeated = true,
        source = 'child',
      },
    },
  },
  backdrop = {
    attributes = {
      edgefile = {
        type = 'string',
      },
      tile = {
        type = 'bool',
      },
    },
    children = {
      backgroundinsets = true,
      edgesize = true,
      tilesize = true,
    },
  },
  backgroundinsets = {
    children = {
      absinset = true,
    },
  },
  barcolor = {
    extends = 'color',
  },
  bartexture = {
    extends = 'texture',
  },
  binding = {
    attributes = {
      category = {
        type = 'string',
      },
      custombindingid = {
        type = 'string',
      },
      debug = {
        type = 'bool',
      },
      default = {
        type = 'string',
      },
      header = {
        type = 'string',
      },
      hidden = {
        type = 'bool',
      },
      name = {
        type = 'string',
      },
      runonup = {
        type = 'bool',
      },
    },
    text = true,
  },
  bindings = {
    children = {
      binding = true,
      modifiedclick = true,
    },
  },
  blingtexture = {
    extends = 'texture',
  },
  browser = {
    attributes = {
      imefont = {
        type = 'string',
      },
    },
    extends = 'frame',
  },
  button = {
    attributes = {
      motionscriptswhiledisabled = {
        type = 'bool',
      },
      registerforclicks = {
        type = 'stringlist',
      },
      text = {
        type = 'string',
      },
    },
    children = {
      buttonfont = true,
      buttontext = true,
      disabledtexture = true,
      highlighttexture = true,
      normaltexture = true,
      pushedtextoffset = true,
      pushedtexture = true,
    },
    extends = 'frame',
  },
  buttonfont = {
    attributes = {
      justifyh = {
        type = 'string',
      },
      style = {
        type = 'string',
      },
    },
    virtual = true,
  },
  buttontext = {
    extends = 'fontstring',
  },
  checkbutton = {
    attributes = {
      checked = {
        type = 'bool',
      },
    },
    children = {
      checkedtexture = true,
      disabledcheckedtexture = true,
    },
    extends = 'button',
  },
  checkedtexture = {
    extends = 'texture',
  },
  checkout = {
    attributes = {
      imefont = {
        type = 'string',
      },
    },
    extends = 'frame',
  },
  cinematicmodel = {
    extends = 'frame',
  },
  color = {
    attributes = {
      a = {
        type = 'number',
      },
      b = {
        type = 'number',
      },
      color = {
        type = 'string',
      },
      g = {
        type = 'number',
      },
      r = {
        type = 'number',
      },
    },
  },
  colorselect = {
    children = {
      colorvaluetexture = true,
      colorvaluethumbtexture = true,
      colorwheeltexture = true,
      colorwheelthumbtexture = true,
    },
    extends = 'frame',
  },
  colorvaluetexture = {
    extends = 'texture',
  },
  colorvaluethumbtexture = {
    extends = 'texture',
  },
  colorwheeltexture = {
    extends = 'texture',
  },
  colorwheelthumbtexture = {
    extends = 'texture',
  },
  containedalertframe = {
    -- TODO support as an intrinsic instead
    extends = 'button',
  },
  controlpoint = {
    attributes = {
      offsetx = {
        type = 'number',
      },
      offsety = {
        type = 'number',
      },
    },
  },
  controlpoints = {
    children = {
      controlpoint = true,
    },
  },
  cooldown = {
    attributes = {
      drawedge = {
        type = 'bool',
      },
      hidecountdownnumbers = {
        type = 'bool',
      },
      reverse = {
        type = 'bool',
      },
    },
    children = {
      blingtexture = true,
      edgetexture = true,
      swipetexture = true,
    },
    extends = 'frame',
  },
  dimension = {
    children = {
      absdimension = true,
    },
    virtual = true,
  },
  disabledcheckedtexture = {
    extends = 'texture',
  },
  disabledfont = {
    extends = 'buttonfont',
  },
  disabledtexture = {
    extends = 'texture',
  },
  dressupmodel = {
    attributes = {
      modelscale = {
        type = 'number',
      },
    },
    extends = 'frame',
  },
  dropdowntogglebutton = {
    -- TODO intrinsic
    extends = 'button',
  },
  edgesize = {
    extends = 'value',
  },
  edgetexture = {
    extends = 'texture',
  },
  editbox = {
    attributes = {
      autofocus = {
        type = 'bool',
      },
      bytes = {
        type = 'number',
      },
      countinvisibleletters = {
        type = 'bool',
      },
      historylines = {
        type = 'number',
      },
      ignorearrows = {
        type = 'bool',
      },
      invisiblebytes = {
        type = 'number',
      },
      letters = {
        type = 'number',
      },
      multiline = {
        type = 'bool',
      },
      numeric = {
        type = 'bool',
      },
      visiblebytes = {
        type = 'number',
      },
    },
    children = {
      fontstring = true,
      highlightcolor = true,
    },
    extends = 'frame',
  },
  eventbutton = {
    -- TODO intrinsic
    extends = 'button',
  },
  eventeditbox = {
    -- TODO intrinsic
    extends = 'editbox',
  },
  eventframe = {
    -- TODO intrinsic
    extends = 'frame',
  },
  fogofwarframe = {
    extends = 'frame',
  },
  font = {
    attributes = {
      filter = {
        type = 'bool',
      },
      fixedsize = {
        type = 'bool',
      },
      font = {
        type = 'string',
      },
      height = {
        type = 'number',
      },
      inherits = {
        type = 'stringlist',
      },
      justifyh = {
        type = 'string',
      },
      justifyv = {
        type = 'string',
      },
      monochrome = {
        type = 'bool',
      },
      name = {
        type = 'string',
      },
      outline = {
        type = 'string',
      },
      spacing = {
        type = 'number',
      },
      virtual = {
        type = 'bool',
      },
    },
    children = {
      color = true,
      shadow = true,
    },
  },
  fontfamily = {
    fields = {
      members = {
        child = 'member',
        repeated = true,
        required = true,
        source = 'child',
      },
      name = {
        required = true,
        source = 'attribute',
        type = 'string',
      },
      virtual = {
        source = 'attribute',
        value = 'true',
      }
    },
  },
  fontheight = {
    extends = 'value',
  },
  fontstring = {
    -- TODO deal with font mixin
    attributes = {
      font = {
        type = 'string',
      },
      justifyh = {
        type = 'string',
      },
      justifyv = {
        type = 'string',
      },
      maxlines = {
        type = 'number',
      },
      nonspacewrap = {
        type = 'bool',
      },
      spacing = {
        type = 'number',
      },
      text = {
        type = 'string',
      },
      wordwrap = {
        type = 'bool',
      },
    },
    children = {
      color = true,
      fontheight = true,
      shadow = true,
    },
    extends = 'layoutframe',
  },
  frame = {
    attributes = {
      clampedtoscreen = {
        type = 'bool',
      },
      clipchildren = {
        type = 'bool',
      },
      debugid = {
        type = 'number',
      },
      dontsaveposition = {
        type = 'bool',
      },
      enablekeyboard = {
        type = 'bool',
      },
      enablemouse = {
        type = 'bool',
      },
      enablemouseclicks = {
        type = 'bool',
      },
      enablemousemotion = {
        type = 'bool',
      },
      enablemousewheel = {
        type = 'bool',
      },
      flattenrenderlayers = {
        type = 'bool',
      },
      framelevel = {
        type = 'number',
      },
      framestrata = {
        type = 'string',
      },
      hyperlinksenabled = {
        type = 'bool',
      },
      id = {
        type = 'number',
      },
      intrinsic = {
        type = 'bool',
      },
      movable = {
        type = 'bool',
      },
      parent = {
        type = 'string',
      },
      propagatehyperlinkstoparent = {
        type = 'bool',
      },
      protected = {
        type = 'bool',
      },
      resizable = {
        type = 'bool',
      },
      toplevel = {
        type = 'bool',
      },
      securemixin = {
        type = 'stringlist',
      },
      useparentlevel = {
        type = 'bool',
      },
    },
    children = {
      animations = true,
      attributes = true,
      backdrop = true,
      frames = true,
      hitrectinsets = true,
      layers = true,
      resizebounds = true,
      scripts = true,
      titleregion = true,
    },
    extends = 'layoutframe',
  },
  frames = {
    fields = {
      frames = {
        child = 'frame',
        repeated = true,
        source = 'child',
      },
    },
  },
  gametooltip = {
    extends = 'frame',
  },
  gradient = {
    attributes = {
      orientation = {
        type = 'string',
      },
    },
    children = {
      maxcolor = true,
      mincolor = true,
    },
  },
  highlightcolor = {
    extends = 'color',
  },
  highlightfont = {
    extends = 'buttonfont',
  },
  highlighttexture = {
    extends = 'texture',
  },
  hitrectinsets = {
    attributes = {
      bottom = {
        type = 'number',
      },
      left = {
        type = 'number',
      },
      right = {
        type = 'number',
      },
      top = {
        type = 'number',
      },
    },
    children = {
      absinset = true,
    },
  },
  include = {
    fields = {
      file = {
        required = true,
        source = 'attribute',
        type = 'string',
      },
    },
  },
  keyvalue = {
    fields = {
      luatype = {
        attribute = 'type',
        source = 'attribute',
        type = 'string',
      },
      key = {
        required = true,
        source = 'attribute',
        type = 'string',
      },
      value = {
        required = true,
        source = 'attribute',
        type = 'string',
      },
    },
  },
  keyvalues = {
    fields = {
      entries = {
        child = 'keyvalue',
        repeated = true,
        source = 'child',
      },
    }
  },
  layer = {
    fields = {
      fontstrings = {
        child = 'fontstring',
        repeated = true,
        source = 'child',
      },
      level = {
        source = 'attribute',
        type = 'string',
      },
      lines = {
        child = 'line',
        repeated = true,
        source = 'child',
      },
      textures = {
        child = 'texture',
        repeated = true,
        source = 'child',
      },
      texturesublevel = {
        source = 'attribute',
        type = 'number',
      },
    },
  },
  layers = {
    fields = {
      layers = {
        child = 'layer',
        repeated = true,
        source = 'child',
      },
    }
  },
  layoutframe = {
    attributes = {
      alpha = {
        type = 'number',
      },
      hidden = {
        type = 'bool',
      },
      ignoreparentalpha = {
        type = 'bool',
      },
      ignoreparentscale = {
        type = 'bool',
      },
      inherits = {
        type = 'stringlist',
      },
      mixin = {
        type = 'stringlist',
      },
      name = {
        type = 'string',
      },
      parentarray = {
        type = 'string',
      },
      parentkey = {
        type = 'string',
      },
      scale = {
        type = 'number',
      },
      setallpoints = {
        type = 'bool',
      },
      virtual = {
        type = 'bool',
      },
    },
    children = {
      anchors = true,
      color = true,
      keyvalues = true,
      size = true,
    },
    virtual = true,
  },
  line = {
    attributes = {
      alphamode = {
        type = 'string',
      },
      atlas = {
        type = 'string',
      },
      thickness = {
        type = 'number',
      },
    },
    extends = 'layoutframe',
  },
  linescale = {
    attributes = {
      fromscalex = {
        type = 'number',
      },
      fromscaley = {
        type = 'number',
      },
      toscalex = {
        type = 'number',
      },
      toscaley = {
        type = 'number',
      },
    },
    children = {
      origin = true,
    },
    extends = 'animation',
  },
  maskedtexture = {
    attributes = {
      childkey = {
        type = 'string',
      },
    },
  },
  maskedtextures = {
    children = {
      maskedtexture = true,
    },
  },
  masktexture = {
    attributes = {
      hwrapmode = {
        type = 'string',
      },
      vwrapmode = {
        type = 'string',
      },
    },
    children = {
      maskedtextures = true,
    },
    extends = 'texture',
  },
  maxcolor = {
    extends = 'color',
  },
  maxresize = {
    extends = 'dimension',
  },
  member = {
    fields = {
      alphabet = {
        required = true,
        source = 'attribute',
        type = 'string',
      },
      font = {
        required = true,
        source = 'child',
      },
    },
  },
  messageframe = {
    attributes = {
      displayduration = {
        type = 'number',
      },
      fadeduration = {
        type = 'number',
      },
      fadepower = {
        type = 'number',
      },
      insertmode = {
        type = 'string',
      },
    },
    children = {
      fontstring = true,
    },
    extends = 'frame',
  },
  mincolor = {
    extends = 'color',
  },
  minimap = {
    extends = 'frame',
  },
  minresize = {
    extends = 'dimension',
  },
  model = {
    extends = 'frame',
  },
  modelscene = {
    children = {
      viewinsets = true,
    },
    extends = 'frame',
  },
  modifiedclick = {
    attributes = {
      action = {
        type = 'string',
      },
      default = {
        type = 'string',
      },
    },
  },
  movieframe = {
    extends = 'frame',
  },
  normalfont = {
    extends = 'buttonfont',
  },
  normaltexture = {
    extends = 'texture',
  },
  offscreenframe = {
    extends = 'frame',
  },
  offset = {
    fields = {
      dim = {
        child = 'absdimension',
        source = 'child',
      },
      x = {
        source = 'attribute',
        type = 'number',
      },
      y = {
        source = 'attribute',
        type = 'number',
      },
    },
  },
  onarrowpressed = {
    extends = 'scripttype',
  },
  onattributechanged = {
    extends = 'scripttype',
  },
  onbuttonupdate = {
    extends = 'scripttype',
  },
  onchar = {
    extends = 'scripttype',
  },
  onclick = {
    extends = 'scripttype',
  },
  oncolorselect = {
    extends = 'scripttype',
  },
  oncursorchanged = {
    extends = 'scripttype',
  },
  ondisable = {
    extends = 'scripttype',
  },
  ondoubleclick = {
    extends = 'scripttype',
  },
  ondragstart = {
    extends = 'scripttype',
  },
  ondragstop = {
    extends = 'scripttype',
  },
  ondressmodel = {
    extends = 'scripttype',
  },
  oneditfocusgained = {
    extends = 'scripttype',
  },
  oneditfocuslost = {
    extends = 'scripttype',
  },
  onenable = {
    extends = 'scripttype',
  },
  onenter = {
    extends = 'scripttype',
  },
  onenterpressed = {
    extends = 'scripttype',
  },
  onerror = {
    extends = 'scripttype',
  },
  onescapepressed = {
    extends = 'scripttype',
  },
  onevent = {
    extends = 'scripttype',
  },
  onexternallink = {
    extends = 'scripttype',
  },
  onfinished = {
    extends = 'scripttype',
  },
  ongamepadbuttondown = {
    extends = 'scripttype',
  },
  ongamepadbuttonup = {
    extends = 'scripttype',
  },
  onhide = {
    extends = 'scripttype',
  },
  onhyperlinkclick = {
    extends = 'scripttype',
  },
  onhyperlinkenter = {
    extends = 'scripttype',
  },
  onhyperlinkleave = {
    extends = 'scripttype',
  },
  oninputlanguagechanged = {
    extends = 'scripttype',
  },
  onkeydown = {
    extends = 'scripttype',
  },
  onkeyup = {
    extends = 'scripttype',
  },
  onleave = {
    extends = 'scripttype',
  },
  onload = {
    extends = 'scripttype',
  },
  onmodelcleared = {
    extends = 'scripttype',
  },
  onmodelloaded = {
    extends = 'scripttype',
  },
  onmousedown = {
    extends = 'scripttype',
  },
  onmoviefinished = {
    extends = 'scripttype',
  },
  onmoviehidesubtitle = {
    extends = 'scripttype',
  },
  onmovieshowsubtitle = {
    extends = 'scripttype',
  },
  onmouseup = {
    extends = 'scripttype',
  },
  onmousewheel = {
    extends = 'scripttype',
  },
  onplay = {
    extends = 'scripttype',
  },
  onreceivedrag = {
    extends = 'scripttype',
  },
  onrequestnewsize = {
    extends = 'scripttype',
  },
  onscrollrangechanged = {
    extends = 'scripttype',
  },
  onshow = {
    extends = 'scripttype',
  },
  onsizechanged = {
    extends = 'scripttype',
  },
  onspacepressed = {
    extends = 'scripttype',
  },
  onstop = {
    extends = 'scripttype',
  },
  ontabpressed = {
    extends = 'scripttype',
  },
  ontextchanged = {
    extends = 'scripttype',
  },
  ontextset = {
    extends = 'scripttype',
  },
  ontooltipaddmoney = {
    extends = 'scripttype',
  },
  ontooltipcleared = {
    extends = 'scripttype',
  },
  ontooltipsetdefaultanchor = {
    extends = 'scripttype',
  },
  ontooltipsetframestack = {
    extends = 'scripttype',
  },
  ontooltipsetitem = {
    extends = 'scripttype',
  },
  ontooltipsetspell = {
    extends = 'scripttype',
  },
  ontooltipsetunit = {
    extends = 'scripttype',
  },
  onupdate = {
    extends = 'scripttype',
  },
  onvaluechanged = {
    extends = 'scripttype',
  },
  onverticalscroll = {
    extends = 'scripttype',
  },
  origin = {
    attributes = {
      point = {
        type = 'string',
      },
    },
    children = {
      offset = true,
    },
  },
  path = {
    attributes = {
      curve = {
        type = 'string',
      },
    },
    children = {
      controlpoints = true,
    },
    extends = 'animation',
  },
  playermodel = {
    extends = 'frame',
  },
  postclick = {
    extends = 'scripttype',
  },
  preclick = {
    extends = 'scripttype',
  },
  pushedtextoffset = {
    extends = 'dimension',
  },
  pushedtexture = {
    extends = 'texture',
  },
  rect = {
    attributes = {
      llx = {
        type = 'number',
      },
      lly = {
        type = 'number',
      },
      lrx = {
        type = 'number',
      },
      lry = {
        type = 'number',
      },
      ulx = {
        type = 'number',
      },
      uly = {
        type = 'number',
      },
      urx = {
        type = 'number',
      },
      ury = {
        type = 'number',
      },
    },
  },
  resizebounds = {
    children = {
      maxresize = true,
      minresize = true,
    },
  },
  rotation = {
    attributes = {
      degrees = {
        type = 'number',
      },
    },
    extends = 'animation',
  },
  scale = {
    attributes = {
      fromscalex = {
        type = 'number',
      },
      fromscaley = {
        type = 'number',
      },
      scalex = {
        type = 'number',
      },
      scaley = {
        type = 'number',
      },
      toscalex = {
        type = 'number',
      },
      toscaley = {
        type = 'number',
      },
    },
    children = {
      origin = true,
    },
    extends = 'animation',
  },
  scenariopoiframe = {
    extends = 'frame',
  },
  scopedmodifier = {
    attributes = {
      forbidden = {
        type = 'bool',
      },
      fulllockdown = {
        type = 'bool',
      },
      scriptsusegivenenv = {
        type = 'bool',
      },
    },
    children = {
      actor = true,
      layoutframe = true,
    },
  },
  script = {
    fields = {
      file = {
        source = 'attribute',
        type = 'string',
      },
    },
    text = true,
  },
  scripts = {
    children = {
      scripttype = true,
    },
  },
  scripttype = {
    fields = {
      autoenableinput = {
        source = 'attribute',
        type = 'bool',
      },
      func = {
        attribute = 'function',
        source = 'attribute',
        type = 'string',
      },
      inherit = {
        source = 'attribute',
        type = 'string',
      },
      intrinsicorder = {
        source = 'attribute',
        type = 'string',
      },
      method = {
        source = 'attribute',
        type = 'string',
      },
    },
    text = true,
    virtual = true,
  },
  scrollchild = {
    fields = {
      frame = {
        required = true,
        source = 'child',
      },
    },
  },
  scrollframe = {
    children = {
      scrollchild = true,
    },
    extends = 'frame',
  },
  scrollingmessageframe = {
    -- TODO intrinsic
    extends = 'frame',
  },
  shadow = {
    attributes = {
      x = {
        type = 'number',
      },
      y = {
        type = 'number',
      },
    },
    children = {
      color = true,
      offset = true,
    },
  },
  simplehtml = {
    children = {
      fontstring = true,
    },
    extends = 'frame',
  },
  size = {
    fields = {
      dim = {
        child = 'absdimension',
        source = 'child',
      },
      x = {
        source = 'attribute',
        type = 'number',
      },
      y = {
        source = 'attribute',
        type = 'number',
      },
    },
  },
  slider = {
    attributes = {
      defaultvalue = {
        type = 'number',
      },
      maxvalue = {
        type = 'number',
      },
      minvalue = {
        type = 'number',
      },
      obeystepondrag = {
        type = 'bool',
      },
      orientation = {
        type = 'string',
      },
      stepsperpage = {
        type = 'number',
      },
      valuestep = {
        type = 'number',
      },
    },
    children = {
      thumbtexture = true,
    },
    extends = 'frame',
  },
  statusbar = {
    attributes = {
      defaultvalue = {
        type = 'number',
      },
      drawlayer = {
        type = 'string',
      },
      maxvalue = {
        type = 'number',
      },
      minvalue = {
        type = 'number',
      },
      reversefill = {
        type = 'bool',
      },
    },
    children = {
      barcolor = true,
      bartexture = true,
    },
    extends = 'frame',
  },
  swipetexture = {
    extends = 'texture',
  },
  tabardmodel = {
    extends = 'frame',
  },
  texcoords = {
    attributes = {
      bottom = {
        type = 'number',
      },
      left = {
        type = 'number',
      },
      right = {
        type = 'number',
      },
      top = {
        type = 'number',
      },
    },
    children = {
      rect = true,
    },
  },
  texture = {
    attributes = {
      alphamode = {
        type = 'string',
      },
      atlas = {
        type = 'string',
      },
      desaturated = {
        type = 'bool',
      },
      horiztile = {
        type = 'bool',
      },
      file = {
        type = 'string',
      },
      nonblocking = {
        type = 'bool',
      },
      snaptopixelgrid = {
        type = 'bool',
      },
      texelsnappingbias = {
        type = 'number',
      },
      useatlassize = {
        type = 'bool',
      },
      verttile = {
        type = 'bool',
      },
    },
    children = {
      animations = true,
      color = true,
      gradient = true,
      texcoords = true,
    },
    extends = 'layoutframe',
  },
  thumbtexture = {
    extends = 'texture',
  },
  tilesize = {
    extends = 'value',
  },
  titleregion = {
    extends = 'layoutframe',
  },
  translation = {
    attributes = {
      offsetx = {
        type = 'number',
      },
      offsety = {
        type = 'number',
      },
    },
    extends = 'animation',
  },
  ui = {
    attributes = {
      ['xmlns'] = {
        type = 'string',
      },
      ['xmlns:xsi'] = {
        type = 'string',
      },
      ['xsi:schemalocation'] = {
        type = 'string',
      },
    },
    children = {
      font = true,
      fontfamily = true,
      include = true,
      layoutframe = true,
      scopedmodifier = true,
      script = true,
    },
  },
  unitpositionframe = {
    extends = 'frame',
  },
  value = {
    children = {
      absvalue = true,
    },
  },
  viewinsets = {
    attributes = {
      bottom = {
        type = 'number',
      },
      left = {
        type = 'number',
      },
      right = {
        type = 'number',
      },
      top = {
        type = 'number',
      },
    },
  },
  worldframe = {
    extends = 'frame',
  },
}
