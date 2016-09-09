require 'spec_helper'

describe BabySqueel::ActiveRecord::QueryMethods, '#joining' do
  context 'when joining explicitly' do
    it 'inner joins' do
      relation = Post.joining {
        author.on(author.id == author_id)
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    it 'inner joins explicitly' do
      relation = Post.joining {
        author.inner.on(author.id == author_id)
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    it 'outer joins' do
      relation = Post.joining {
        author.outer.on(author.id == author_id)
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        LEFT OUTER JOIN "authors" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    it 'self joins' do
      relation = Post.joining { on(id == 1) }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "posts" ON "posts"."id" = 1
      EOSQL
    end

    it 'self outer joins' do
      relation = Post.joining { outer.on(id == 1) }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        LEFT OUTER JOIN "posts" ON "posts"."id" = 1
      EOSQL
    end

    it 'self joins with alias' do
      relation = Post.joining {
        on(id == 1).alias('meatloaf')
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "posts" "meatloaf" ON "posts"."id" = 1
      EOSQL
    end

    it 'aliases' do
      relation = Post.joining {
        author.alias('a').on(author.id == author_id)
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "authors" "a" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    it 'aliases after the on clause' do
      relation = Post.joining {
        author.on(author.id == author_id).alias('a')
      }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "authors" "a" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    it 'merges bind values' do
      relation = Post.joining { ugly_author_comments }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        INNER JOIN "authors" ON "authors"."id" = "posts"."author_id" AND "authors"."ugly" = 't'
        INNER JOIN "comments" ON "comments"."author_id" = "authors"."id"
      EOSQL
    end

    context 'with complex conditions' do
      it 'inner joins' do
        relation = Post.joining {
          author.on(
            (author_id == author.id) & (author.id != 5) | (author.name == nil)
          )
        }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          INNER JOIN "authors" ON (
            "posts"."author_id" = "authors"."id" AND
            "authors"."id" != 5 OR
            "authors"."name" IS NULL
          )
        EOSQL
      end

      it 'outer joins' do
        relation = Post.joining {
          author.outer.on(
            (author_id == author.id) & (author.id != 5) | (author.name == nil)
          )
        }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          LEFT OUTER JOIN "authors" ON (
            "posts"."author_id" = "authors"."id" AND
            "authors"."id" != 5 OR
            "authors"."name" IS NULL
          )
        EOSQL
      end
    end
  end

  context 'when joining implicitly' do
    it 'inner joins' do
      relation = Post.joining { author }
      expect(relation).to produce_sql(Post.joins(:author))
    end

    it 'outer joins' do
      relation = Post.joining { author.outer }

      expect(relation).to produce_sql(<<-EOSQL)
        SELECT "posts".* FROM "posts"
        LEFT OUTER JOIN "authors" ON "authors"."id" = "posts"."author_id"
      EOSQL
    end

    describe 'polymorphism' do
      it 'inner joins' do
        relation = Picture.joining { imageable(Post) }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "pictures".* FROM "pictures"
          INNER JOIN "posts" ON "posts"."id" = "pictures"."imageable_id" AND "pictures"."imageable_type" = 'Post'
        EOSQL
      end

      it 'outer joins' do
        relation = Picture.joining { imageable(Post).outer }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "pictures".* FROM "pictures"
          LEFT OUTER JOIN "posts" ON "posts"."id" = "pictures"."imageable_id" AND "pictures"."imageable_type" = 'Post'
        EOSQL
      end
    end

    describe 'nested joins' do
      it 'inner joins' do
        relation = Post.joining { author.comments }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
          INNER JOIN "comments" ON "comments"."author_id" = "authors"."id"
        EOSQL
      end

      it 'outer joins' do
        relation = Post.joining { author.outer.comments }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          LEFT OUTER JOIN "authors" ON "authors"."id" = "posts"."author_id"
          INNER JOIN "comments" ON "comments"."author_id" = "authors"."id"
        EOSQL
      end

      it 'handles polymorphism' do
        relation = Picture.joining { imageable(Post).comments }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "pictures".* FROM "pictures"
          INNER JOIN "posts" ON "posts"."id" = "pictures"."imageable_id" AND "pictures"."imageable_type" = 'Post'
          INNER JOIN "comments" ON "comments"."post_id" = "posts"."id"
        EOSQL
      end

      it 'outer joins at multiple levels' do
        relation = Post.joining { author.outer.comments.outer }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          LEFT OUTER JOIN "authors" ON "authors"."id" = "posts"."author_id"
          LEFT OUTER JOIN "comments" ON "comments"."author_id" = "authors"."id"
        EOSQL
      end

      it 'outer joins only the specified associations' do
        relation = Post.joining { author.comments.outer }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
          LEFT OUTER JOIN "comments" ON "comments"."author_id" = "authors"."id"
        EOSQL
      end

      it 'joins back with a new alias' do
        baby_squeel = Post.joining { author.posts }
        active_record = Post.joins(author: :posts)
        expect(baby_squeel).to produce_sql(active_record)
      end

      it 'prevents mutation of the original instance' do
        relation = Post.joining {
          author.posts # this should have absolutely no effect
          author
        }

        expect(relation).to produce_sql(Post.joins(:author))
      end

      it 'joins a through association' do
        baby_squeel = Post.joining { author.posts.author_comments }
        active_record = Post.joins(author: { posts: :author_comments})
        expect(baby_squeel).to produce_sql(active_record)
      end

      it 'joins a through association and then back again' do
        relation = Post.joining { author.posts.author_comments.outer.post.author_comments }

        expect(relation).to produce_sql(<<-EOSQL)
          SELECT "posts".* FROM "posts"
          INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
          INNER JOIN "posts" "posts_authors" ON "posts_authors"."author_id" = "authors"."id"
          LEFT OUTER JOIN "authors" "authors_posts_join" ON "authors_posts_join"."id" = "posts_authors"."author_id"
          LEFT OUTER JOIN "comments" ON "comments"."author_id" = "authors_posts_join"."id"
          INNER JOIN "posts" "posts_comments" ON "posts_comments"."id" = "comments"."post_id"
          INNER JOIN "authors" "authors_posts_join_2" ON "authors_posts_join_2"."id" = "posts_comments"."author_id"
          INNER JOIN "comments" "author_comments_posts" ON "author_comments_posts"."author_id" = "authors_posts_join_2"."id"
        EOSQL
      end
    end

    describe 'duplicate prevention' do
      context 'when given two DSL joins' do
        it 'dedupes' do
          relation = Post.joining { author }.joining { author }
          expect(relation).to produce_sql(Post.joins(:author))
        end

        it 'dedupes incremental joins' do
          relation = Post.joining { author }.joining { author.posts }

          expect(relation).to produce_sql(<<-EOSQL)
            SELECT "posts".* FROM "posts"
            INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
            INNER JOIN "posts" "posts_authors" ON "posts_authors"."author_id" = "authors"."id"
          EOSQL
        end
      end

      context 'when given a DSL join with an Active Record join' do
        it 'dedupes' do
          relation = Post.joining { author }.joins(:author)
          expect(relation).to produce_sql(Post.joins(:author))
        end

        it 'dedupes (in any order)' do
          relation = Post.joins(:author).joining { author }
          expect(relation).to produce_sql(Post.joins(:author))
        end

        it 'dedupes through joins' do
          relation = Post.joins(author: { posts: :author_comments })
                         .joining { author.posts.author_comments.outer }

          # There are duplicate inner joins in here, but that'll have to do...
          expect(relation).to produce_sql(<<-EOSQL)
            SELECT "posts".* FROM "posts"
            INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
            INNER JOIN "posts" "posts_authors" ON "posts_authors"."author_id" = "authors"."id"
            INNER JOIN "authors" "authors_posts_join" ON "authors_posts_join"."id" = "posts_authors"."author_id"
            INNER JOIN "comments" ON "comments"."author_id" = "authors_posts_join"."id"
            INNER JOIN "authors" "authors_posts" ON "authors_posts"."id" = "posts"."author_id"
            INNER JOIN "posts" "posts_authors_2" ON "posts_authors_2"."author_id" = "authors_posts"."id"
            LEFT OUTER JOIN "authors" "authors_posts_join_2" ON "authors_posts_join_2"."id" = "posts_authors_2"."author_id"
            LEFT OUTER JOIN "comments" "author_comments_posts" ON "author_comments_posts"."author_id" = "authors_posts_join_2"."id"
          EOSQL
        end

        it 'dedupes incremental outer joins' do
          relation = Post.joins(:author).joining { author.comments.outer }

          expect(relation).to produce_sql(<<-EOSQL)
            SELECT "posts".* FROM "posts"
            INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
            INNER JOIN "authors" "authors_posts" ON "authors_posts"."id" = "posts"."author_id"
            LEFT OUTER JOIN "comments" ON "comments"."author_id" = "authors_posts"."id"
          EOSQL
        end

        it 'dedupes incremental outer joins (in any order)' do
          relation = Post.joining { author.comments.outer }.joins(:author)

          expect(relation).to produce_sql(<<-EOSQL)
            SELECT "posts".* FROM "posts"
            INNER JOIN "authors" ON "authors"."id" = "posts"."author_id"
            LEFT OUTER JOIN "comments" ON "comments"."author_id" = "authors"."id"
            INNER JOIN "authors" "authors_posts" ON "authors_posts"."id" = "posts"."author_id"
          EOSQL
        end
      end

      context 'when given a DSL join with an Arel join' do
        let(:arel_join) {
          Arel::Nodes::InnerJoin.new(
            Author.arel_table,
            Arel::Nodes::On.new(
              Post.arel_table[:author_id].eq(
                Author.arel_table[:id]
              )
            )
          )
        }

        it 'does what Active Record would do' do
          baby_squeel = Post.joining { author }.joins(arel_join)
          active_record = Post.joins(:author).joins(arel_join)
          expect(baby_squeel).to produce_sql(active_record)
        end

        it 'does what Active Record would do (in any order)' do
          baby_squeel = Post.joins(arel_join).joining { author }
          active_record = Post.joins(arel_join).joins(:author)
          expect(baby_squeel).to produce_sql(active_record.to_sql)
        end
      end
    end

    it 'raises an error when attempting to alias an inner join' do
      expect {
        Post.joining { author.alias('a') }.to_sql
      }.to raise_error(BabySqueel::AssociationAliasingError, /'author' as 'a'/)
    end

    it 'raises an error when attempting to alias an outer join' do
      expect {
        Post.joining { author.outer.alias('a') }.to_sql
      }.to raise_error(BabySqueel::AssociationAliasingError, /'author' as 'a'/)
    end
  end
end
