-- Development seed: mirrors the in-app demo dataset (Austin, TX).
insert into public.stores (id, name, chain, address, lat, lng, opening_hours) values
  ('aldi-1', 'Aldi', 'aldi', '2610 E Riverside Dr, Austin, TX', 30.2401, -97.7269, '{"1":"08:00-21:00","2":"08:00-21:00","3":"08:00-21:00","4":"08:00-21:00","5":"08:00-21:00","6":"08:00-21:00","7":"09:00-20:00"}'),
  ('walmart-1', 'Walmart Supercenter', 'walmart', '710 E Ben White Blvd, Austin, TX', 30.2201, -97.7570, '{"1":"06:00-23:00","2":"06:00-23:00","3":"06:00-23:00","4":"06:00-23:00","5":"06:00-23:00","6":"06:00-23:00","7":"06:00-23:00"}'),
  ('kroger-1', 'Kroger', 'kroger', '1601 W 38th St, Austin, TX', 30.3055, -97.7484, '{"1":"07:00-22:00","2":"07:00-22:00","3":"07:00-22:00","4":"07:00-22:00","5":"07:00-22:00","6":"07:00-22:00","7":"08:00-21:00"}'),
  ('target-1', 'Target', 'target', '5300 S MoPac Expy, Austin, TX', 30.2320, -97.8100, '{"1":"08:00-22:00","2":"08:00-22:00","3":"08:00-22:00","4":"08:00-22:00","5":"08:00-22:00","6":"08:00-22:00","7":"08:00-21:00"}'),
  ('heb-1', 'H-E-B', 'heb', '2400 S Congress Ave, Austin, TX', 30.2410, -97.7515, '{"1":"06:00-23:00","2":"06:00-23:00","3":"06:00-23:00","4":"06:00-23:00","5":"06:00-23:00","6":"06:00-23:00","7":"06:00-23:00"}'),
  ('tj-1', 'Trader Joe''s', 'traderjoes', '211 Walter Seaholm Dr, Austin, TX', 30.2680, -97.7530, '{"1":"08:00-21:00","2":"08:00-21:00","3":"08:00-21:00","4":"08:00-21:00","5":"08:00-21:00","6":"08:00-21:00","7":"08:00-21:00"}')
on conflict (id) do nothing;

insert into public.products (id, name, brand, barcode, category, unit, unit_size, tags) values
  ('milk', 'Whole Milk', 'Great Value', '0001001', 'dairy', 'gal', 1, '{}'),
  ('eggs', 'Large Eggs, Dozen', null, '0001002', 'dairy', 'ct', 12, '{}'),
  ('butter', 'Salted Butter', 'Land O Lakes', '0001003', 'dairy', 'oz', 16, '{}'),
  ('cheddar', 'Shredded Cheddar', null, '0001004', 'dairy', 'oz', 8, '{}'),
  ('yogurt', 'Greek Yogurt', 'Chobani', '0001005', 'dairy', 'oz', 32, '{}'),
  ('bananas', 'Bananas', null, '0001006', 'produce', 'lb', 1, '{vegan}'),
  ('apples', 'Gala Apples', null, '0001007', 'produce', 'lb', 1, '{vegan}'),
  ('lettuce', 'Romaine Lettuce', null, '0001008', 'produce', 'ea', 1, '{vegan}'),
  ('tomatoes', 'Roma Tomatoes', null, '0001009', 'produce', 'lb', 1, '{vegan}'),
  ('broccoli', 'Broccoli Crowns', null, '0001010', 'produce', 'lb', 1, '{vegan}'),
  ('chicken', 'Chicken Breast', null, '0001011', 'meat', 'lb', 1, '{}'),
  ('gbeef', 'Ground Beef 80/20', null, '0001012', 'meat', 'lb', 1, '{}'),
  ('turkey', 'Ground Turkey', null, '0001013', 'meat', 'lb', 1, '{}'),
  ('bread', 'Whole Wheat Bread', 'Nature''s Own', '0001014', 'bakery', 'loaf', 1, '{}'),
  ('tortillas', 'Flour Tortillas', 'Mission', '0001015', 'bakery', 'ct', 10, '{}'),
  ('rice', 'Long Grain Rice', null, '0001016', 'pantry', 'lb', 2, '{vegan}'),
  ('pasta', 'Spaghetti', 'Barilla', '0001017', 'pantry', 'oz', 16, '{vegan}'),
  ('beans', 'Black Beans', 'Goya', '0001018', 'pantry', 'can', 1, '{vegan}'),
  ('tomsauce', 'Canned Tomatoes', 'Hunt''s', '0001019', 'pantry', 'can', 1, '{vegan}'),
  ('pb', 'Peanut Butter', 'Jif', '0001020', 'pantry', 'oz', 16, '{vegan}'),
  ('cereal', 'Honey Nut Cereal', 'General Mills', '0001021', 'pantry', 'oz', 18, '{}'),
  ('coffee', 'Ground Coffee', 'Folgers', '0001022', 'beverages', 'oz', 24, '{vegan}'),
  ('oj', 'Orange Juice', 'Tropicana', '0001023', 'beverages', 'oz', 52, '{vegan}'),
  ('frbroccoli', 'Frozen Broccoli', null, '0001024', 'frozen', 'oz', 12, '{vegan}'),
  ('icecream', 'Vanilla Ice Cream', 'Blue Bell', '0001025', 'frozen', 'oz', 16, '{}'),
  ('tofu', 'Firm Tofu', null, '0001026', 'meat', 'oz', 14, '{vegan}')
on conflict (id) do nothing;

-- Representative prices (subset; ingestion jobs keep these fresh).
insert into public.prices (product_id, store_id, price, unit_price) values
  ('milk', 'aldi-1', 3.00, 3.00), ('milk', 'walmart-1', 3.21, 3.21), ('milk', 'kroger-1', 3.56, 3.56), ('milk', 'heb-1', 3.32, 3.32), ('milk', 'target-1', 3.70, 3.70), ('milk', 'tj-1', 3.84, 3.84),
  ('eggs', 'aldi-1', 2.49, 0.21), ('eggs', 'walmart-1', 2.66, 0.22), ('eggs', 'kroger-1', 2.95, 0.25), ('eggs', 'heb-1', 2.75, 0.23), ('eggs', 'target-1', 3.06, 0.26), ('eggs', 'tj-1', 3.18, 0.27),
  ('chicken', 'aldi-1', 2.83, 2.83), ('chicken', 'walmart-1', 3.03, 3.03), ('chicken', 'kroger-1', 2.62, 2.62), ('chicken', 'heb-1', 3.13, 3.13), ('chicken', 'target-1', 3.49, 3.49), ('chicken', 'tj-1', 3.62, 3.62),
  ('bread', 'aldi-1', 2.14, 2.14), ('bread', 'walmart-1', 2.29, 2.29), ('bread', 'kroger-1', 2.54, 2.54), ('bread', 'heb-1', 2.37, 2.37),
  ('pasta', 'aldi-1', 1.20, 0.07), ('pasta', 'walmart-1', 1.00, 0.06), ('pasta', 'kroger-1', 1.42, 0.09), ('pasta', 'heb-1', 1.32, 0.08)
on conflict (product_id, store_id) do nothing;

insert into public.offers (store_id, product_id, title, description, type, discount_percent, valid_to) values
  ('kroger-1', 'chicken', 'Chicken Breast 22% off', 'Weekly ad — fresh chicken breast value pack.', 'weeklyAd', 22, now() + interval '4 days'),
  ('heb-1', 'gbeef', 'Ground Beef sale', null, 'weeklyAd', 22, now() + interval '2 days'),
  ('walmart-1', null, '5% cashback on $50+ baskets', 'Walmart+ members earn cashback this week.', 'cashback', 5, now() + interval '6 days'),
  ('target-1', 'coffee', 'Coffee BOGO 50% off', null, 'bogo', 25, now() + interval '5 days'),
  ('aldi-1', null, 'Produce Wednesday: extra 10% off produce', null, 'discount', 10, now() + interval '3 days');

insert into public.coupons (store_id, product_id, title, code, discount_amount, discount_percent, min_spend, expires_at) values
  ('kroger-1', 'cereal', '$1 off Honey Nut Cereal', 'CEREAL1', 1.00, null, null, now() + interval '2 days'),
  (null, null, '$5 off any $40 basket', 'SAVE5', 5.00, null, 40, now() + interval '10 days'),
  ('heb-1', 'yogurt', '20% off Greek Yogurt', null, null, 20, null, now() + interval '5 days'),
  ('walmart-1', 'pb', '50c off Peanut Butter', null, 0.50, null, null, now() + interval '1 day');
