part of ice_tests;

full_tests() {
  group("initial UI", (){
    tearDown(()=> document.query('#ice').remove());

    test("the editor is full-screen", (){
      var it = new Full(enable_javascript_mode: false);

      _test(_) {
        var el = document.query('#ice');
        var editor_el = el.query('.ice-code-editor-editor');
        expect(editor_el.clientWidth, window.innerWidth);
        expect(editor_el.clientHeight, closeTo(window.innerHeight,1.0));
      };
      it.editorReady.then(expectAsync1(_test));
    });

    //test("has a default project", (){});
  });

  group("main toolbar", (){
    setUp(()=> new Full(enable_javascript_mode: false));
    tearDown(()=> document.query('#ice').remove());

    test("it has a menu button", (){
      var buttons = document.queryAll('button');
      expect(buttons.any((e)=> e.text=='☰'), isTrue);
    });

    test("clicking the menu button brings up the menu", (){
      helpers.click('button', text: '☰');

      var menu = queryAll('li').
        firstWhere((e)=> e.text.contains('Help'));

      expect(menu, isNotNull);
    });

    test("clicking the menu button a second time hides the menu", (){
      helpers.click('button', text: '☰');
      expect(queryAll('li'), helpers.elementsContain('Help'));

      helpers.click('button', text: '☰');
      expect(queryAll('li'), helpers.elementsAreEmpty);
    });
  });

  group("sharing", (){
    setUp(()=> new Full(enable_javascript_mode: false));
    tearDown(()=> document.query('#ice').remove());

    test("clicking the share link shows the share dialog", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text:  'Share');

      expect(
        queryAll('div'),
        helpers.elementsContain('Copy this link')
      );
    });

    skip_test("there is a modal overlay behind the dialog", (){});
    skip_test("share link is encoded", (){});
    skip_test("menu should close when share dialog activates", (){});
  });

  group("project menu", (){
    var editor;

    setUp(()=> editor = new Full(enable_javascript_mode: false));
    tearDown(() {
      document.query('#ice').remove();
      new Store().clear();
    });

    test("clicking the project menu item opens the project dialog", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');

      expect(
        queryAll('div'),
        helpers.elementsContain('Saved Projects')
      );
    });

    test("clicking the project menu item closes the main menu", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');

      expect(
        queryAll('li'),
        helpers.elementsDoNotContain('Help')
      );
    });

    test("the escape key closes the project dialog", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');

      document.body.dispatchEvent(
        new KeyboardEvent(
          'keyup',
          keyIdentifier: new String.fromCharCode(27)
        )
      );

      expect(
        queryAll('div'),
        helpers.elementsDoNotContain(new RegExp('Saved'))
      );
    });

    test("the menu button closes the projects dialog", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');
      helpers.click('button', text: '☰');

      expect(
        queryAll('div'),
        helpers.elementsDoNotContain('Saved Projects')
      );
    });

    test("lists project names", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      query('input').value = 'My New Project';

      helpers.click('button', text: 'Save');

      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');

      expect(
        queryAll('div'),
        helpers.elementsContain('My New Project')
      );
    });

    test("click names to switch between projects", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      query('input').value = 'Project #1';
      helpers.click('button', text: 'Save');

      editor.content = 'Code #1';
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Save');

      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      query('input').value = 'Project #2';
      helpers.click('button', text: 'Save');

      editor.content = 'Code #2';
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Save');

      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');
      helpers.click('li', text: 'Project #1');

      expect(
        editor.content,
        equals('Code #1')
      );
    });

    test("closes when a project is selected", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      query('input').value = 'Project #1';
      helpers.click('button', text: 'Save');

      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Projects');
      helpers.click('li', text: 'Project #1');

      expect(queryAll('li'), helpers.elementsAreEmpty);
    });


    skip_test("contains a default project on first load", (){});
  });

  group("new project", (){
    var editor;

    setUp(()=> editor = new Full(enable_javascript_mode: false));
    tearDown(() {
      document.query('#ice').remove();
      new Store().clear();
    });

    test("can be named", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      query('input').value = 'My New Project';

      helpers.click('button', text: 'Save');

      editor.content = 'asdf';

      helpers.click('button', text: '☰');
      helpers.click('li', text: 'Save');

      // TODO: check the projects menu (once implemented)
      var store = new Store();
      expect(store['My New Project'], isNotNull);
      expect(store['My New Project']['code'], 'asdf');
    });

    test("clicking the new menu item closes the main menu", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text:  'New');

      expect(queryAll('li'), helpers.elementsAreEmpty);
    });

    test("the escape key closes the new project dialog", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text: 'New');

      document.body.dispatchEvent(
        new KeyboardEvent(
          'keyup',
          keyIdentifier: new String.fromCharCode(27)
        )
      );

      expect(
        queryAll('button'),
        helpers.elementsDoNotContain('Save')
      );
    });
  });

  group("saving projects", (){
    var editor;

    setUp(()=> editor = new Full(enable_javascript_mode: false));
    tearDown(() {
      document.query('#ice').remove();
      new Store().clear();
    });

    test("a saved project is loaded when the editor starts", (){
      editor.content = 'asdf';

      helpers.click('button', text: '☰');
      helpers.click('li', text:  'Save');

      document.query('#ice').remove();
      editor = new Full(enable_javascript_mode: false);

      _test(_) {
        expect(editor.content, equals('asdf'));
      };
      editor.editorReady.then(expectAsync1(_test));
    });

    test("clicking save closes the main menu", (){
      helpers.click('button', text: '☰');
      helpers.click('li', text:  'Save');

      expect(queryAll('li'), helpers.elementsAreEmpty);
    });

    skip_test("", (){});
  });
}
