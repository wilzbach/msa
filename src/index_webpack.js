// trick to bundle the css
require('./../css/msa.css');
import * as MSA from "./index";
if (!!window) {
    window.msa = MSA;
}
export default MSA;
