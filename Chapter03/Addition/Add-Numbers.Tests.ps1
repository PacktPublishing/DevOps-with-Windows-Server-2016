$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$here
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$sut

. "$here\$sut"
"$here\$sut"

Describe "test cases additing two numbers" {

    it "checking when both the number are positive" {

        $FirstNumber = 10
        $SecondNumber = 20

        Add-Numbers -Num1 $FirstNumber -Num2 $SecondNumber | should be 30
     }

     it "checking when One number is positive and another negative" {

        $FirstNumber = -10
        $SecondNumber = 20

        Add-Numbers -Num1 $FirstNumber -Num2 $SecondNumber | should be 10
     }
}
