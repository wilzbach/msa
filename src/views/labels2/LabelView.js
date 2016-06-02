import { h, Component } from 'preact';

export default class LabelView extends Component {
   render({ seq, g }) {
		return (
			<div class="biojs_msa_labels" style={{width: `${g.zoomer.getLabelWidth()}px`,
                                            fontSize: `${g.zoomer.get('labelFontsize')}px`}}>
				{ g.vis.get("labelCheckbox") ? (
                    <input type="checkbox" value={seq.id} name="seq" style={{width: g.zoomer.get("labelCheckLength") + "px"}} />
				) : null }
				{ g.vis.get("labelId") ? (
                    <span style={{display: "inline-block", width: g.zoomer.get("labelIdLength") + "px"}}>
                        {seq.get("id")}
                    </span>
				) : null }
				{ g.vis.get("labelName") ? (
                     <span style={{width: g.zoomer.get("labelNameLength") + "px"}}>
                        {seq.get("name")}
                     </span>
				) : null }
			</div>
		);
	}
}
