-- CreateEnum
CREATE TYPE "TaskPriorityType" AS ENUM ('low', 'medium', 'high');

-- CreateTable
CREATE TABLE "Task" (
    "id" TEXT NOT NULL,
    "label" TEXT,
    "priority" "TaskPriorityType",
    "isComplete" BOOLEAN,
    "assignedTo" TEXT,
    "finishBy" TIMESTAMP(3),

    PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Person" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "password" TEXT,

    PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Task.assignedTo_index" ON "Task"("assignedTo");

-- CreateIndex
CREATE UNIQUE INDEX "Person.email_unique" ON "Person"("email");

-- AddForeignKey
ALTER TABLE "Task" ADD FOREIGN KEY ("assignedTo") REFERENCES "Person"("id") ON DELETE SET NULL ON UPDATE CASCADE;
