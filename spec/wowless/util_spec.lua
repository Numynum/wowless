describe('util', function()
  local util = require('wowless.util')
  describe('strjoin', function()
    it('returns empty with no elements', function()
      assert.same('', util.strjoin('foo'))
    end)
    it('returns just the element when only one', function()
      assert.same('bar', util.strjoin('foo', 'bar'))
    end)
    it('joins', function()
      assert.same('barfoobazfooquux', util.strjoin('foo', 'bar', 'baz', 'quux'))
    end)
  end)
  describe('strsplit', function()
    it('does nothing on empty string', function()
      assert.same({''}, {util.strsplit('.', '')})
    end)
    it('does nothing on string without separator', function()
      assert.same({'foo'}, {util.strsplit('.', 'foo')})
    end)
    it('splits', function()
      assert.same({'foo', 'bar'}, {util.strsplit('.', 'foo.bar')})
    end)
    it('respects max split parameter', function()
      assert.same({'a', 'b', 'c.d'}, {util.strsplit('.', 'a.b.c.d', 3)})
    end)
    it('returns original string when max is one', function()
      assert.same({'a.b.c.d'}, {util.strsplit('.', 'a.b.c.d', 1)})
    end)
  end)
  describe('strtrim', function()
    it('does nothing when nothing to trim', function()
      assert.same('foo', util.strtrim('foo'))
    end)
    it('trims', function()
      assert.same('foo', util.strtrim(' foo '))
    end)
  end)
end)
