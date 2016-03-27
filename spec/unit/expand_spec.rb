# encoding: utf-8

RSpec.describe TTY::Prompt, '#say' do

  subject(:prompt) { TTY::TestPrompt.new }

  it "expands default option" do
    choices = [{
      key: 'Y',
      name: 'Overwrite',
      value: :yes
    }, {
      key: 'n',
      name: 'Skip',
      value: :no
    }, {
      key: 'a',
      name: 'Overwrite all',
      value: :all
    }, {
      key: 'd',
      name: 'Show diff',
      value: :diff
    }, {
      key: 'q',
      name: 'Quit',
      value: :quit
    }]

    prompt.input << "\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:yes)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? \e[90m(enter \"h\" for help) [Y,n,a,d,q,h] \e[0m",
      "\e[1000D\e[K",
      "Overwrite Gemfile? \e[32mOverwrite\e[0m\n"
    ].join)
  end

  it "expands chosen option with extra information" do
    choices = [{
      key: 'Y',
      name: 'Overwrite',
      value: :yes
    }, {
      key: 'n',
      name: 'Skip',
      value: :no
    }, {
      key: 'a',
      name: 'Overwrite all',
      value: :all
    }, {
      key: 'd',
      name: 'Show diff',
      value: :diff
    }, {
      key: 'q',
      name: 'Quit',
      value: :quit
    }]

    prompt.input << "a\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:all)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? \e[90m(enter \"h\" for help) [Y,n,a,d,q,h] \e[0m",
      "\e[1000D\e[K",
      "Overwrite Gemfile? \e[90m(enter \"h\" for help) [Y,n,a,d,q,h] \e[0m",
      "a\n",
      "\e[32m>> \e[0mOverwrite all",
      "\e[F\e[55C",
      "\e[1000D\e[K",
      "\e[1B",
      "\e[1000D\e[K",
      "\e[F",
      "Overwrite Gemfile? \e[32mOverwrite all\e[0m\n"
    ].join)
  end

  it "expands help option and then defaults" do
    choices = [ {
      key: 'Y',
      name: 'Overwrite',
      value: :yes
    }, {
      key: 'n',
      name: 'Skip',
      value: :no
    }, {
      key: 'a',
      name: 'Overwrite all',
      value: :all
    }, {
      key: 'd',
      name: 'Show diff',
      value: :diff
    }, {
      key: 'q',
      name: 'Quit',
      value: :quit
    } ]

    prompt.input << "h\nd\n"
    prompt.input.rewind

    result = prompt.expand('Overwrite Gemfile?', choices)
    expect(result).to eq(:diff)

    expect(prompt.output.string).to eq([
      "Overwrite Gemfile? \e[90m(enter \"h\" for help) [Y,n,a,d,q,h] \e[0m",
      "\e[1000D\e[K",
      "Overwrite Gemfile? \e[90m(enter \"h\" for help) [Y,n,a,d,q,h] \e[0mh\n",
      "\e[32m>> \e[0mprint help",
      "\e[F\e[55C",
      "\e[1000D\e[K",
      "\e[1B",
      "\e[1000D\e[K",
      "\e[F",
      "Overwrite Gemfile? \n",
      "Y - Overwrite\n",
      "n - Skip\n",
      "a - Overwrite all\n",
      "d - Show diff\n",
      "q - Quit\n",
      "h - print help\n",
      "Choice [Y]: ",
      "\e[1000D\e[K\e[1A" * 7,
      "\e[1000D\e[K",
      "Overwrite Gemfile? \n",
      "Y - Overwrite\n",
      "n - Skip\n",
      "a - Overwrite all\n",
      "\e[32md - Show diff\e[0m\n",
      "q - Quit\n",
      "h - print help\n",
      "Choice [Y]: d",
      "\e[1000D\e[K\e[1A" * 7,
      "\e[1000D\e[K",
      "Overwrite Gemfile? \e[32mShow diff\e[0m\n",
    ].join)
  end

  it "fails to expand due to lack of key attribute" do
    choices = [{ name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice Overwrite is missing a :key attribute/)
  end

  it "fails to expand due to wrong key length" do
    choices = [{ key: 'long', name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `long` is more than one character long/)
  end

  it "fails to expand due to reserve key" do
    choices = [{ key: 'h', name: 'Overwrite', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `h` is reserved for help menu/)
  end

  it "fails to expand due to duplicate key" do
    choices = [{ key: 'y', name: 'Overwrite', value: :yes },
               { key: 'y', name: 'Change', value: :yes }]

    expect {
      prompt.expand('Overwrite Gemfile?', choices)
    }.to raise_error(TTY::Prompt::ConfigurationError, /Choice key `y` is a duplicate/)
  end
end