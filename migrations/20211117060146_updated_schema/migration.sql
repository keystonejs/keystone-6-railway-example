/*
  Warnings:

  - The `priority` column on the `Task` table would be dropped and recreated. This will lead to data loss if there is data in the column.
  - Made the column `name` on table `Person` required. This step will fail if there are existing NULL values in that column.
  - Made the column `email` on table `Person` required. This step will fail if there are existing NULL values in that column.
  - Made the column `label` on table `Task` required. This step will fail if there are existing NULL values in that column.
  - Made the column `isComplete` on table `Task` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Person" ALTER COLUMN "name" SET NOT NULL,
ALTER COLUMN "name" SET DEFAULT E'',
ALTER COLUMN "email" SET NOT NULL,
ALTER COLUMN "email" SET DEFAULT E'';

-- AlterTable
ALTER TABLE "Task" ALTER COLUMN "label" SET NOT NULL,
ALTER COLUMN "label" SET DEFAULT E'',
DROP COLUMN "priority",
ADD COLUMN     "priority" TEXT,
ALTER COLUMN "isComplete" SET NOT NULL,
ALTER COLUMN "isComplete" SET DEFAULT false;

-- DropEnum
DROP TYPE "TaskPriorityType";

-- RenameIndex
ALTER INDEX "Person.email_unique" RENAME TO "Person_email_key";

-- RenameIndex
ALTER INDEX "Task.assignedTo_index" RENAME TO "Task_assignedTo_idx";
