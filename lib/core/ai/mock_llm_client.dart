import 'llm_client.dart';

/// Offline/demo LLM. Returns deterministic, well-formed responses keyed
/// off intent markers that the AI services embed in their prompts, so
/// every AI feature is demonstrable without an API key.
class MockLlmClient implements LlmClient {
  const MockLlmClient();

  @override
  String get providerName => 'mock';

  @override
  Future<String> complete(LlmRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final prompt =
        '${request.system ?? ''}\n${request.messages.map((m) => m.content).join('\n')}'
            .toLowerCase();

    if (prompt.contains('[intent:meal_plan]')) return _mealPlan;
    if (prompt.contains('[intent:generate_list]')) return _groceryList;
    if (prompt.contains('[intent:substitute]')) return _substitutions;
    if (prompt.contains('[intent:recipe]')) return _recipe;
    if (prompt.contains('[intent:receipt_summary]')) return _receiptSummary;
    if (prompt.contains('[intent:explain_trip]')) return _explainTrip;
    return _chatFallback(prompt);
  }

  static const _mealPlan = '''
{"meals":[
 {"day":"Monday","type":"dinner","name":"Chickpea curry with rice","usesPantry":["rice","chickpeas"],"ingredients":["chickpeas","coconut milk","curry paste","rice","onion"],"estimatedCost":6.80},
 {"day":"Tuesday","type":"dinner","name":"Sheet-pan chicken & vegetables","usesPantry":["olive oil"],"ingredients":["chicken thighs","broccoli","carrots","potatoes"],"estimatedCost":9.40},
 {"day":"Wednesday","type":"dinner","name":"Black bean tacos","usesPantry":["black beans","taco shells"],"ingredients":["black beans","taco shells","lettuce","tomato","cheddar"],"estimatedCost":7.10},
 {"day":"Thursday","type":"dinner","name":"Pasta with tomato basil sauce","usesPantry":["pasta"],"ingredients":["pasta","canned tomatoes","basil","parmesan"],"estimatedCost":5.90},
 {"day":"Friday","type":"dinner","name":"Veggie stir-fry with tofu","usesPantry":["soy sauce","rice"],"ingredients":["tofu","bell pepper","snap peas","rice","ginger"],"estimatedCost":8.20}
]}''';

  static const _groceryList = '''
{"name":"Weekly essentials under budget","items":[
 {"name":"Whole milk","quantity":1,"unit":"gal","estimatedPrice":3.49},
 {"name":"Eggs, dozen","quantity":1,"unit":"ct","estimatedPrice":2.89},
 {"name":"Bananas","quantity":2,"unit":"lb","estimatedPrice":1.16},
 {"name":"Chicken thighs","quantity":2,"unit":"lb","estimatedPrice":5.98},
 {"name":"Brown rice","quantity":1,"unit":"bag","estimatedPrice":2.79},
 {"name":"Black beans","quantity":3,"unit":"can","estimatedPrice":2.67},
 {"name":"Frozen broccoli","quantity":2,"unit":"bag","estimatedPrice":3.58},
 {"name":"Whole wheat bread","quantity":1,"unit":"loaf","estimatedPrice":2.49},
 {"name":"Peanut butter","quantity":1,"unit":"jar","estimatedPrice":3.29},
 {"name":"Pasta","quantity":2,"unit":"box","estimatedPrice":2.38}
],"estimatedTotal":30.72,"notes":"Leaves headroom under budget for produce on sale."}''';

  static const _substitutions = '''
{"substitutions":[
 {"original":"Boneless ribeye steak","replacement":"Chuck roast","savings":6.50,"reason":"Same braise-friendly beef flavor at half the unit price."},
 {"original":"Pine nuts","replacement":"Sunflower seeds","savings":4.20,"reason":"Comparable crunch in pesto and salads for 80% less."},
 {"original":"Fresh raspberries","replacement":"Frozen mixed berries","savings":2.75,"reason":"Frozen keeps longer and works in smoothies and baking."}
]}''';

  static const _recipe = '''
{"name":"Cheapest taco dinner","servings":4,"totalCost":11.40,
 "ingredients":[
  {"name":"Ground turkey","quantity":"1 lb","cost":3.99},
  {"name":"Taco shells","quantity":"12 ct","cost":1.99},
  {"name":"Black beans","quantity":"1 can","cost":0.89},
  {"name":"Shredded cheddar","quantity":"8 oz","cost":2.29},
  {"name":"Lettuce","quantity":"1 head","cost":1.49},
  {"name":"Tomato","quantity":"2","cost":0.75}
 ],
 "steps":["Brown the turkey with taco seasoning.","Warm shells and beans.","Assemble with toppings."]}''';

  static const _explainTrip =
      'This trip wins on the all-in number, not just shelf prices: after '
      'subtracting your clipped coupons and adding what the driving '
      'actually costs, it comes out cheapest for completing your whole '
      'list. A shorter trip exists, but it gives up more in savings than '
      'it returns in time — about a coffee\'s worth per extra minute. If '
      'your schedule is tight today, option A remains a solid single-stop '
      'fallback.';

  static const _receiptSummary =
      '''You spent \$54.20 across 18 items. Produce (\$14.10) and dairy (\$11.30) led. Prices were typical except strawberries, \$1.20 above their 90-day average — they go on sale most weeks at Kroger, so consider timing that purchase.''';

  String _chatFallback(String prompt) {
    if (prompt.contains('wait') || prompt.contains('next week')) {
      return 'Based on 12 weeks of price history, chicken breast at Aldi '
          'drops to about \$1.99/lb during their first-week-of-month sale — '
          'that is 4 days away. If your pantry covers dinners until then, '
          'waiting saves roughly \$4 on your list.';
    }
    return 'I can build budget grocery lists, plan meals around your pantry, '
        'find cheaper substitutes, and tell you which store combination '
        'completes your list for the least money. Try: '
        '"Build me a grocery list under \$40."';
  }
}
