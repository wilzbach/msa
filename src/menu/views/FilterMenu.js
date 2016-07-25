import MenuBuilder from "../menubuilder";

const FilterMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    return this.el.style.display = "inline-block";
  },

  render: function() {
    this.setName("Filter");
    this.addNode("Hide columns by threshold",(e) => {
      let threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      const maxLen = this.model.getMaxLength();
      const hidden = [];
      // TODO: cache this value
      const conserv = this.g.stats.scale(this.g.stats.conservation());
      const end = maxLen - 1;
      for (let i = 0; i <= end; i++) {
        if (conserv[i] < threshold) {
          hidden.push(i);
        }
      }
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide columns by selection", () => {
      const hiddenOld = this.g.columns.get("hidden");
      const hidden = hiddenOld.concat(this.g.selcol.getAllColumnBlocks({maxLen: this.model.getMaxLength(), withPos: true}));
      this.g.selcol.reset([]);
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide columns by gaps", () => {
      let threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      const maxLen = this.model.getMaxLength();
      const hidden = [];
      const end = maxLen - 1;
      for (let i = 0; i <= end; i++) {
        let gaps = 0;
        let total = 0;
        this.model.each((el) => {
          if (el.get('seq')[i] === "-") { gaps++; }
          return total++;
        });
        const gapContent = gaps / total;
        if (gapContent > threshold) {
          hidden.push(i);
        }
      }
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide seqs by identity", () => {
      let threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      return this.model.each((el) => {
        if (el.get('identity') < threshold) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Hide seqs by selection", () => {
      const hidden = this.g.selcol.where({type: "row"});
      const ids = hidden.map((el) => el.get('seqId'));
      this.g.selcol.reset([]);
      return this.model.each((el) => {
        if (ids.indexOf(el.get('id')) >= 0) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Hide seqs by gaps", () => {
      const threshold = prompt("Enter threshold (in percent)", 40);
      return this.model.each((el,i) => {
        const seq = el.get('seq');
        const gaps = seq.reduce((memo, c) => c === '-' ? ++memo: undefined,0);
        if (gaps >  threshold) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Reset", () => {
      this.g.columns.set("hidden", []);
      return this.model.each((el) => {
        if (el.get('hidden')) {
          return el.set('hidden', false);
        }
      });
    });

    this.el.appendChild(this.buildDOM());
    return this;
  }
});
export default FilterMenu;
