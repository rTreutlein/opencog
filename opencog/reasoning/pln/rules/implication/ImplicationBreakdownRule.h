#ifndef IMPBREAKDOWNRULE_H
#define IMPBREAKDOWNRULE_H

namespace reasoning
{

/// (x->A) => A.
class ImplicationBreakdownRule : public Rule
{
public:
	NO_DIRECT_PRODUCTION;

	ImplicationBreakdownRule(iAtomSpaceWrapper *_destTable);
	Rule::setOfMPs o2iMetaExtra(meta outh, bool& overrideInputFilter) const;
	BoundVertex compute(const vector<Vertex>& premiseArray, Handle CX = Handle::UNDEFINED) const;
	bool validate2				(MPs& args) const { return true; }
};

} // namespace reasoning
#endif // IMPBREAKDOWNRULE_H
