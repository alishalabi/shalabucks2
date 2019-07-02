// COURTESY OF @maurelian: https://github.com/ConsenSys/Tokens/blob/master/test/helpers/assertRevert.js

module.exports = {
    assertRevert: async (promise) => {
      try {
        await promise;
      } catch (error) {
        const revertFound = error.message.search('revert') >= 0;
        assert(revertFound, `Expected "revert", got ${error} instead`);
        return;
      }
      assert.fail('Expected revert not received');
    },
  };
