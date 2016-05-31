import { h, Component } from 'preact';
import LabelView from './LabelView';

export default class LabelRowView extends Component {
    render({seq, g}){
        return (
            <div class="biojs_msa_labelrow" style={{
                height: g.zoomer.get('rowHeight') * (seq.attributes.height || 1) + 'px',
                fontWeight: "normal"
            }}>
                <LabelView seq={seq} g={g} />
            </div>
        );
    }
}
