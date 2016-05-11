// trick to bundle the css
require('./../css/msa.css');
import * as MSA from './index';
const msa = MSA.default;
// workaround against es6 exports
// we want to expose the MSA constructor by default
for (var key in MSA) {
    if (MSA.hasOwnProperty(key)) {
        msa[key] = MSA[key];
    }
}
if (!!window) {
    window.msa = msa;
}
module.exports = msa;
