def setup
    Article.create!(title: 'Test Article', published_at: Time.now - 5.days)
    Article.create!(title: 'Another Article', published_at: Time.now - 3.days)
  end

  def test_find_by_single_field
    article = Article.find_by(title: 'Test Article')
    assert_equal 'Test Article', article.title
  end

  def test_find_by_multiple_fields
    article = Article.find_by(title: 'Another Article', published_at: Time.now - 3.days)
    assert_equal 'Another Article', article.title
  end

  def test_find_by_conditions
    article = Article.find_by("published_at < ?", Time.now - 4.days)
    assert_equal 'Test Article', article.title
  end

  def test_find_by_no_match
    assert_nil Article.find_by(title: 'Nonexistent')
  end

  def test_find_by_nil_field
    assert_nil Article.find_by(title: nil)
  end
