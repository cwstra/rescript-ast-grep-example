let useMyOuterHook = () => {
  let [testValue] = useMyInnerHook()
  let (testValue, a) = useMyInnerHook()
  let {testValue} = useMyInnerHook()
  let a = testValue
  useMyInnerHook()
}
