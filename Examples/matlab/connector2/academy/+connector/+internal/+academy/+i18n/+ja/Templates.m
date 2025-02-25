classdef Templates
    
    properties (Constant)
        zeroth = '0';
        first = '1';
        second = '2';
        third = '3';
        fourth = '4';
        fifth = '5';
        sixth = '6';
        seventh = '7';
        eighth = '8';
        ninth = '9';
        tenth = '10';
        %MINUS = 'subtraction operator';
        MINUS = '減算 演算子';
        %MUL = 'matrix multiplication operator';
        MUL = '行列乗算 演算子';
        %DIV = 'divide operator';
        DIV = '行列除算 演算子';
        %LDIV = 'backslash operator';
        LDIV = '行列左除算 演算子';
        %EXP = 'exponent operator';
        EXP = '行列べき乗 演算子';
        %DOTMUL = 'dot multiply operator';
        DOTMUL = '乗算 演算子';
        %DOTDIV = 'dot divide operator';
        DOTDIV = '除算 演算子';
        %DOTLDIV = 'dot backslash operator';
        DOTLDIV = '左除算 演算子';
        %DOTEXP = 'dot exponent operator';
        DOTEXP = 'べき乗 演算子';
        %ANDAND = 'logical AND operator';
        ANDAND = 'ショートサーキット論理 AND 演算子';
        %OROR = 'logical OR operator';
        OROR = 'ショートサーキット論理 OR 演算子';
        %LT = 'less than operator';
        LT = '小なり 演算子';
        %GT = 'greater than operator';
        GT = '大なり 演算子';
        %LE = 'less than or equal to operator';
        LE = '以下 演算子';
        %GE = 'greater than or equal to operator';
        GE = '以上 演算子';
        %PLUS = 'addition operator';
        PLUS = '加算 演算子';
        %AND = 'logical AND operator';
        AND = '論理 AND 演算子';
        %OR = 'logical OR operator';
        OR = '論理 OR 演算子';
        %EQ = 'equality operator';
        EQ = '等号 演算子';
        %NE = 'inequality operator';
        NE = '不等号 演算子';
        %NOT = 'logical NOT operator';
        NOT = '論理 NOT 演算子';
        %UMINUS = 'unary minus operator';
        UMINUS = '単項マイナス 演算子';
        %UPLUS = 'unary plus operator';
        UPLUS = '単項プラス 演算子';
        %DOTTRANS = 'transpose operator';
        DOTTRANS = '転置 演算子';
        %TRANS = 'transpose operator';
        TRANS = '複素共役転置 演算子';
        %AT = 'function handle operator';
        AT = '関数ハンドル 演算子';
        %BANG = 'bang operator';
        BANG = '感嘆符';
        %syntaxError = 'Syntax error. ';
        syntaxError = '構文エラー';
        %correct = 'Correct! ';
        correct = '正解';
        %incorrect = 'Incorrect! ';
        incorrect = '不正解';
        %example = 'Example: ';
        example = '例: ';
        %missingSingleQuotes = 'Use single quotes ('''') around the string <code>${1}</code> to treat it as a MATLAB character array. ';
        missingSingleQuotes = '<code>${1}</code> を単一引用符 ('') で囲って MATLAB の文字配列として定義します。';
        %squareBracketForArrayAccess = 'If you are trying to use [] for accessing array elements, remember that MATLAB uses (). ';
        squareBracketForArrayAccess = 'MATLAB では、[] ではなく () を使って配列の要素にアクセスします。';
        %shouldCallAFunction = 'Your solution should use the <code>${1}</code> function. ';
        shouldCallAFunction = '関数 <code>${1}</code> を使う必要があります。';
        %shouldNotCallAFunction = 'Your solution does not need to use the <code>${1}</code> function. ';
        shouldNotCallAFunction = '関数 <code>${1}</code> を使う必要はありません。';
        %shouldIndexIntoVariable = 'Your solution should index into the <code>${1}</code> variable. ';
        shouldIndexIntoVariable = '変数 <code>${1}</code> にインデックス参照する必要があります。';
        %shouldNotIndexIntoVariable = 'Your solution does not need to index into the <code>${1}</code> variable. ';
        shouldNotIndexIntoVariable = '変数 <code>${1}</code> にインデックス参照する必要はありません。';
        %shouldUseVariable = 'Your solution should access the <code>${1}</code> variable. ';
        shouldUseVariable = '変数 <code>${1}</code> を参照する必要があります。';
        %shouldNotUseVariable = 'Your solution does not need to access the <code>${1}</code> variable. ';
        shouldNotUseVariable = '変数 <code>${1}</code> を参照する必要はありません。';
        %shouldModifyVariable = 'Your solution should modify the <code>${1}</code> variable. ';
        shouldModifyVariable = '変数 <code>${1}</code> を変更する必要があります。';
        %shouldNotModifyVariable = 'Your solution does not need to modify the <code>${1}</code> variable. ';
        shouldNotModifyVariable = '変数 <code>${1}</code> を変更する必要はありません。';
        %shouldExtractContentFrom = 'Your solution should use curly braces to extract contents from the <code>${1}</code> array. ';
        shouldExtractContentFrom = '中かっこを使って配列 <code>${1}</code> から内容を抽出する必要があります。';
        %shouldNotExtractContentFrom = 'Your solution does not need to extract contents from the <code>${1}</code> array. ';
        shouldNotExtractContentFrom = '配列 <code>${1}</code> から内容を抽出する必要はありません。';
        %shouldModifyContentWithin = 'Your solution should use curly braces to modify the content within the <code>${1}</code> array. ';
        shouldModifyContentWithin = '中かっこを使って配列 <code>${1}</code> の内容を変更する必要があります。';
        %shouldNotModifyContentWithin = 'Your solution should not use curly braces to modify the content within the <code>${1}</code> array. ';
        shouldNotModifyContentWithin = '中かっこを使って配列 <code>${1}</code> の内容を変更する必要はありません。';
        %functionCallShouldUseParentheses = 'The call to <code>${1}</code> should use parentheses <code>()</code> to pass the arguments. ';
        functionCallShouldUseParentheses = '関数 <code>${1}</code> の呼び出しには 小かっこ <code>()</code> を使って入力を渡す必要があります。';
        %indexShouldUseParentheses = 'Try using parentheses <code>()</code> when indexing into <code>${1}</code>. ';
        indexShouldUseParentheses = '変数 <code>${1}</code> へインデックス参照する場合は 小かっこ <code>()</code> を使います。';
        %indexShouldUseCurlyBraces = 'Try using curly braces <code>{}</code> when indexing into <code>${1}</code>. ';
        indexShouldUseCurlyBraces = '変数 <code>${1}</code> へインデックス参照する場合は中かっこ <code>{}</code> を使います。';
        %callShouldHaveDifferentNumberOfInputs = 'The call to the <code>${1}</code> function should contain ${2} input(s). ';
        callShouldHaveDifferentNumberOfInputs = '関数 <code>${1}</code> の呼び出しには ${2} つの入力引数が必要です。';
        %indexShouldHaveDifferentNumberOfInputs = 'When indexing into <code>${1}</code>, consider using ${2} input(s). ';
        indexShouldHaveDifferentNumberOfInputs = '変数 <code>${1}</code> へインデックス参照する場合は ${2} つ入力引数が必要です。';
        %inputsAreIncorrect = 'The inputs to <code>${1}</code> are incorrect. ';
        inputsAreIncorrect = '<code>${1}</code> への入力は間違っています。';
        %inputWasExpectedToBeDifferent = 'The ${1} input was expected to have the value <code>${2}</code>. ';
        inputWasExpectedToBeDifferent = '${1} 番目の入力引数には <code>${2}</code> という値が必要です。';
        %inputArgumentIsNotInCorrectSpot = '<code>${1}</code> was expected to be the ${2} input, not the ${3}. ';
        inputArgumentIsNotInCorrectSpot = '<code>${1}</code> は ${3} 番目ではなく ${2} 番目でなくてはなりません。';
        %noNeedToObtainMultipleOutputArguments = 'Your solution does not need to obtain multiple outputs. ';
        noNeedToObtainMultipleOutputArguments = '複数の出力を指定する必要はありません。';
        %shouldObtainMultipleOutputArguments = 'Try using square brackets (<code>[]</code>) to obtain multiple outputs. ';
        shouldObtainMultipleOutputArguments = '複数の出力を指定するには角かっこ (<code>[]</code>) を使います。';
        %noNeedToManuallyCreateArray = 'Your solution does not need to manually create arrays with square brackets (<code>[]</code>). ';
        noNeedToManuallyCreateArray = '角かっこ (<code>[]</code>) を使って手作業で配列を作成する必要はありません。';
        %shouldManuallyCreateArray = 'Try using square brackets to manually enter an array (<code>[3 5 8]</code>) . ';
        shouldManuallyCreateArray = '角かっこを使って手作業で配列を作成します (<code>[3 5 8]</code>)。';
        %noNeedToRemoveArrayElements = 'Your solution does not need to remove array elements (<code>... = []</code>). ';
        noNeedToRemoveArrayElements = '配列の要素を削除する必要はありません (<code>... = []</code>)。';
        %shouldRemoveArrayElements = 'Try removing array elements by making an assignment to the empty array (<code>... = []</code>). ';
        shouldRemoveArrayElements = '空の配列を代入することによって配列の要素を削除できます (<code>... = []</code>)。';
        %noNeedToCreateAnEmptyArray = 'Your solution does not need to create an empty array (<code>[]</code>). ';
        noNeedToCreateAnEmptyArray = '空の配列を作成する必要はありません (<code>[]</code>)。';
        %shouldCreateAnEmptyArray = 'Try using an empty array (<code>[]</code>) in your submission. ';
        shouldCreateAnEmptyArray = '空の配列を作成しましょう (<code>[]</code>)。';
        %noNeedToManuallyCreateCellArray = 'Your solution does not need to manually create cell arrays with curly braces (<code>{}</code>). ';
        noNeedToManuallyCreateCellArray = '中かっこ (<code>{}</code>) を使って手作業でセル配列を作成する必要はありません。';
        %shouldManuallyCreateCellArray = 'Try using curly braces to manually create a cell array (<code>{3 ''foo'' 8}</code>) . ';
        shouldManuallyCreateCellArray = '中かっこを使って手作業で配列を作成します (<code>{3 ''foo'' 8}</code>)。';
        %noNeedToCreateEmptyCellArray = 'Your solution does not need to create an empty cell array (<code>{}</code>). ';
        noNeedToCreateEmptyCellArray = '空のセル配列を作成する必要はありません (<code>{}</code>)。';
        %shouldCreateEmptyCellArray = 'Try using an empty cell array (<code>{}</code>) in your submission. ';
        shouldCreateEmptyCellArray = '空のセル配列を作成しましょう (<code>{}</code>)。';
        %incorrectUseOfMultipleOutputArgs = 'The output argument expression seems incorrect. ';
        incorrectUseOfMultipleOutputArgs = '出力引数の構文が間違っています。';
        %incorrectUseOfManuallyCreatingArrays = 'The array being created using square brackets (<code>[]</code>) seems incorrect. ';
        incorrectUseOfManuallyCreatingArrays = '角かっこ (<code>[]</code>) を使った配列の作成方法が間違っています。';
        %incorrectUseOfRemovingArrayElements = 'There is an issue with the way array elements are being removed. '; 
        incorrectUseOfRemovingArrayElements = '配列要素の削除の方法が間違っています。';
        %incorrectUseOfCreatingEmptyArray = 'There is an issue with the way the empty array is created. ';
        incorrectUseOfCreatingEmptyArray = '空の配列の作成方法が間違っています。';
        %incorrectUseOfManuallyCreatingCellArrays = 'The cell array being created using curly braces (<code>{}</code>) seems incorrect. ';
        incorrectUseOfManuallyCreatingCellArrays = '中かっこ (<code>{}</code>) を使ったセル配列の作成方法が間違っています。';
        %incorrectUseOfCreatingEmptyCellArray = 'There is an issue with the way the empty cell array is created. ';
        incorrectUseOfCreatingEmptyCellArray = '空のセル配列の作成方法が間違っています。';
        %expectedMRows = 'There were expected to be ${1} row(s). ';
        expectedMRows = '${1} 行あるべきです。';
        %rowSeparationTip = 'Remember that you can use a semicolon (<code>;</code>) to separate rows. ';
        rowSeparationTip = 'セミコロン (<code>;</code>) を使って行を区切ります。';
        %expectedNColumns = 'The ${1} row was expected to have ${2} columns. ';
        expectedNColumns = '${1} 行目は ${2} 列あるべきです。 ';
        %columnSeparationTip = 'Remember that you can use a comma (<code>,</code>) or space to separate columns. ';
        columnSeparationTip = 'コンマ (<code>,</code>) またはスペースを使って列を区切ります。';
        %expectedDifferentRowArgument = 'The ${1} value of the ${2} row was expected to be <code>${3}</code>. ';
        expectedDifferentRowArgument = '${2} 行目の ${1} 番目の値は <code>${3}</code> であるべきです。';
        %switchedArgumentOrderInRow = 'In the ${1} row, <code>${2}</code> should be the ${3} argument. ';
        switchedArgumentOrderInRow = '${1} 行目では、 <code>${2}</code> は ${3} 番目の引数である必要があります。';
        %shouldNotUseColon = 'Your solution does not need to use the colon (<code>:</code>) operator. '; 
        shouldNotUseColon = 'コロン演算子 (<code>:</code>) を使う必要はありません。';
        %useColonToAccessAllElements = 'Try using the colon operator (<code>${1}</code>) to access all elements of an array. ';
        useColonToAccessAllElements = 'コロン演算子 (<code>${1}</code>) を使って配列の全ての要素にアクセスします。';
        %useColonToAccessAllRows = 'Try using the colon operator (<code>${1}</code>) to access all rows. ';
        useColonToAccessAllRows = 'コロン演算子 (<code>${1}</code>) を使って全ての行にアクセスします。';
        %useColonToAccessAllColumns = 'Try using the colon operator (<code>${1}</code>) to access all columns. ';
        useColonToAccessAllColumns = 'コロン演算子 (<code>${1}</code>) を使って全ての列にアクセスします。';
        %useColonToAccessAllElementsOfADimension = 'Try using the colon operator (<code>${1}</code>) to access all elements of a particular dimension. ';
        useColonToAccessAllElementsOfADimension = 'コロン演算子 (<code>${1}</code>) を使って特定の次元の全ての要素にアクセスします。';
        %useColonToCreateVector = 'Try using the colon operator (<code>${1}</code>) to create a vector. ';
        useColonToCreateVector = 'コロン演算子 (<code>${1}</code>) を使ってベクトルを作成します。';
        %needToUseALoneColon = 'Use a single colon (<code>${1}</code>) within a subscript to select an entire row or column. ';
        needToUseALoneColon = '単一のコロン (<code>${1}</code>) を添字内で使って、行または列を選択します。';
        %needToSpecifyInitialAndFinalValue = 'The initial and final value of the vector should be specified in the colon (<code>${1}</code>) operator. ';
        needToSpecifyInitialAndFinalValue = 'コロン演算子 (<code>${1}</code>) ではベクトルの最初と最後の値を指定する必要があります。';
        %badStartValueInColonExpression = 'The initial value of the vector should be <code>${1}</code>. ';
        badStartValueInColonExpression = 'ベクトルの最初の値は <code>${1}</code> でなければなりません。';
        %badSpacingValueInColonExpression = 'The spacing of the vector should be <code>${1}</code>. ';
        badSpacingValueInColonExpression = 'ベクトルの間隔は <code>${1}</code> でなければなりません。';
        %badEndValueInColonExpression = 'The final value of the vector should be <code>${1}</code>. ';
        badEndValueInColonExpression = 'ベクトルの最後の値は <code>${1}</code> でなければなりません。';
        %unnecessaryStatement = 'Your solution does not need to use a <code>${1}</code> statement. ';
        unnecessaryStatement = '<code>${1}</code> ステートメントを使う必要はありません。';
        %missingStatement = 'Use a <code>${1}</code> statement in your solution. ';
        missingStatement = '<code>${1}</code> ステートメントを使う必要があります。';
        %noNeedToUseDotOperator = 'You do not need to use the dot operator (<code>a.b</code>) in your submission. ';
        noNeedToUseDotOperator = 'ドット演算子 (<code>a.b</code>) を使う必要はありません。';
        %shouldUseDotOperator = 'Try using the dot operator (<code>a.b</code>) in your submission. ';
        shouldUseDotOperator = 'ドット演算子 (<code>a.b</code>) を使う必要があります。';
        %useDotOperatorOnVariable = 'Use the dot operator (<code>.</code>) to reference a field of the variable <code>${1}</code>. ';
        useDotOperatorOnVariable = 'ドット演算子 (<code>.</code>) を使って変数 <code>${1}</code> のフィールドを参照します。';
        %checkVariableNameCapitalization = 'Check the variable name capitalization. ';
        checkVariableNameCapitalization = '変数の名前が大文字もしくは、小文字かどうか確認してください。';
        %useDotOperatorForField = 'Use the dot operator (<code>.</code>) to reference the property <code>${1}</code>. ';
        useDotOperatorForField = 'ドット演算子 (<code>.</code>) を使ってプロパティ <code>${1}</code> を参照します。';
        %noAssignmentNecessary = 'Your solution does not need to assign the value to an output variable. ';
        noAssignmentNecessary = '値を変数に代入する必要はありません。';
        %shouldUseAssignment = 'Your solution should assign the value to <code>${1}</code>. ';
        shouldUseAssignment = '値を <code>${1}</code> に代入する必要があります。';
        %valueAssignedIncorrect = 'The value being assigned is incorrect. ';
        valueAssignedIncorrect = '代入されている値が間違っています。';
        %wrongVariableInAssignment = 'Your solution should assign the value to <code>${1}</code>. ';
        wrongVariableInAssignment = '値を <code>${1}</code> に代入する必要があります。';
        %switchedAssignmentOrder = 'The inputs of the assignment are switched. They should be <code>${1}</code>. ';
        switchedAssignmentOrder = '代入のための入力が逆です。<code>${1}</code> であるべきです。';
        %valueBeingAssignedShouldBeOutput = 'The value being assigned ( <code>${1}</code> ) should be the output argument. ';
        valueBeingAssignedShouldBeOutput = '代入されている値 ( <code>${1}</code> ) は出力引数でなければなりません。';
        %outputShouldBeValueBeingAssigned = 'The output argument of the assignment ( <code>${1}</code> ) should instead be the value being assigned. ';
        outputShouldBeValueBeingAssigned = '出力に指定された変数 ( <code>${1}</code> ) は右辺に代入します。';
        %anonymousFunction = 'anonymous function';
        anonymousFunction = '無名関数';
        %anonymousFunctionUnnecessary = 'Your solution does not need to use an ${1}. ';
        anonymousFunctionUnnecessary = '${1} を使う必要はありません。';
        %tryUsingAnonymousFunction = 'Try using an ${1} in your solution. ';
        tryUsingAnonymousFunction = '${1} を使います。';
        %anonFunctionHasWrongNumInputs = 'The anonymous function was expected to contain ${1} inputs. ';
        anonFunctionHasWrongNumInputs = 'この無名関数には ${1} 個の入力引数が必要です。';
        %noNeedToUseOperator = 'Your solution does not need to use the ${1} (<a target="_blank" href="${2}">${3}</a>). ';
        noNeedToUseOperator = '${1} (<a target="_blank" href="${2}">${3}</a>) を使う必要はありません。';
        %shouldUseOperator = 'Your solution should use the ${1} (<a target="_blank" href="${2}">${3}</a>). ';
        shouldUseOperator = '${1} (<a target="_blank" href="${2}">${3}</a>) を使います。';
        %left = 'left';
        left = '左';
        %right = 'right';
        right = '右';
        %badOperatorArgument = 'The ${1} input to the ${2} was expected to be <code>${3}</code>. ';
        badOperatorArgument = '${2} の ${1} 側の入力は <code>${3}</code> でなければなりません';
        %switchedBothOperatorArguments = 'The inputs to the ${1} are switched. They should be <code>${2}</code>. ';        
        switchedBothOperatorArguments = '${1} の入力が逆になっています。正しくは <code>${2}</code> です。';        
        %switchedOneOperatorArgument = 'The ${1} input to the ${2} ( <code>${3}</code> ) should be the ${4} input. ';
        switchedOneOperatorArgument = ' ${2} ( <code>${3}</code> ) の ${1} 側の入力は ${4} 側の入力でなければなりません。';
        %shouldUseInt = 'Your solution should contain an integer with the value <code>${1}</code>. ';
        shouldUseInt = '<code>${1}</code> の値を持つ整数型でなければなりません。';
        %noNeedToUseInt = 'Your solution does not need to contain an integer with the value <code>${1}</code>. ';
        noNeedToUseInt = '<code>${1}</code> の値を持つ整数型である必要はありません。';
        %shouldUseDouble = 'Your solution should contain a number with the value <code>${1}</code>. ';
        shouldUseDouble = '<code>${1}</code> の値を持つ倍精度型でなければなりません。';
        %noNeedToUseDouble = 'Your solution does not need to contain a number with the value <code>${1}</code>. ';
        noNeedToUseDouble = '<code>${1}</code> の値を持つ倍精度型である必要はありません。';
        %shouldUseString = 'Your solution should contain a character array with the value <code>${1}</code>. ';
        shouldUseString = '<code>${1}</code> の値を持つ文字型でなければなりません。';
        %noNeedToUseString = 'Your solution does not need to contain a character array with the value <code>${1}</code>. ';
        noNeedToUseString = '<code>${1}</code> の値を持つ文字型である必要はありません。';
        %shouldUseId = 'Your solution should contain a reference to the identifier <code>${1}</code>. ';
        shouldUseId = '識別子 <code>${1}</code> を参照しなければなりません。';
        %noNeedToUseId = 'Your solution does not need to contain a reference to the identifier <code>${1}</code>. ';
        noNeedToUseId = '識別子 <code>${1}</code> を参照する必要はありません。';
        
        %variableHasIncorrectDimensions = 'The variable <code>${1}</code> has incorrect dimensions. <br/>Expected size: [${2}] <br/>Actual size: [${3}]';
        variableHasIncorrectDimensions = '変数 <code>${1}</code> は間違った次元を持っています。<br/>正しいサイズ: [${2}] <br/>現在のサイズ: [${3}]';
        %variableHasIncorrectDataType = 'The variable <code>${1}</code> has incorrect datatype. <br/>Expected type: [${2}] <br/>Actual type: [${3}]'; 
        variableHasIncorrectDataType = '変数 <code>${1}</code> は間違ったデータ型を持っています。<br/>: [${2}] <br/>Actual type: [${3}]'; 
        %variableIsIncorrect = 'The variable <code>${1}</code> appears to be incorrect. ';
        variableIsIncorrect = '変数 <code>${1}</code> は間違っています。';
        %checkCapitalizationOfCharacters = 'Check the case of each character in the string <code>${1}</code>. ';
        checkCapitalizationOfCharacters = '文字列 <code>${1}</code> の大文字と小文字を確認してください。';
        %stateDesiredValue = 'The desired value of <code>${1}</code> is: ${2} <br/>The actual value is: ${3}';
        stateDesiredValue = '<code>${1}</code> の値は ${2} でなければなりません。<br/>現在の値は ${3} です。';
        %variableWasNotCreated = 'The variable <code>${1}</code> was not created. ';
        variableWasNotCreated = '変数 <code>${1}</code> が作成されませんでした。';
        %checkMisspelledVariableName = 'Check if you have misspelled the variable name <code>${1}</code>. ';
        checkMisspelledVariableName = '変数 <code>${1}</code> のつづりを確認してください。';
        %scalarValueDifference = 'The value differs from the desired value by an amount on the order of <code>${1}</code>. ';
        scalarValueDifference = '値が期待している値と <code>${1}</code> 桁ほど離れています。';
        %nonscalarValueDifference = 'One or more elements differ the desired value by an amount on the order of <code>${1}</code>. ';
        nonscalarValueDifference = '一つ以上の要素の値が期待している値から <code>${1}</code> 桁ほど離れています。';
        %missingStructField = 'The field <code>${1}</code> is missing from the structure. ';
        missingStructField = 'フィールド <code>${1}</code> が構造体に含まれていません。';
        %missingSeveralStructFields = 'These fields are missing from the structure: <code>${1}</code>. ';
        missingSeveralStructFields = 'このフィールドが構造体に含まれていません： <code>${1}</code>';
        %checkMisspelledFieldName = 'Check if you have misspelled the field name(s) ${1}. ';
        checkMisspelledFieldName = 'フィールドの名前のつづりを確認してください： ${1} ';
        %checkMisspelledFieldNameGeneric = 'Check if you misspelled any of the field names. ';
        checkMisspelledFieldNameGeneric = 'フィールドの名前を確認してください。';
        %checkFieldValue = 'Check the value of the field(s): ${1}';
        checkFieldValue = 'フィールドの値を確認してください： ${1}';
        %incorrectTableVariableOrder = 'The variables of the table are not in the correct order. ';
        incorrectTableVariableOrder = 'テーブルの変数の順序が間違っています。';
        %tableVariableCapitalizationIssue = 'The table''s variable names are case sensitive. Check if the variable names have the proper case. ';
        tableVariableCapitalizationIssue = 'テーブルの変数名は大文字と小文字を区別しています。名前が正しいか確認してください。';
        %checkTableVariableValues = 'Check the value of the following variables of the table: ${1}';
        checkTableVariableValues = 'テーブルの変数の値を確認してください： ${1}';
    end
    
end

