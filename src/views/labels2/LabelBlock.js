import { h, Component } from 'preact';
import LabelRowView from './LabelRowView';

export default class LabelBlock extends Component {
    render({seqs, g}){
        return (
            <div class="biojs_msa_labelblock" style={{
                display: 'inline-block',
                verticalAlign: 'top',
                overflowY: 'auto',
                overflowX: 'hidden',
                fontSize: `${g.zoomer.get('labelFontsize')}px`,
                lineHeight: `${g.zoomer.get('labelLineHeight')}`,
                height: g.zoomer.get("alignmentHeight") + "px"
            }}>

            { seqs.map((seq, i) => (
                <LabelRowView seq={seq} g={g} />
            ))}
            </div>
        );
    }
}
