CREATE TABLE [dbo].[ToDos] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [Owner]       UNIQUEIDENTIFIER NOT NULL,
    [Description] NVARCHAR (MAX)   NOT NULL,
    CONSTRAINT [PK_ToDos] PRIMARY KEY CLUSTERED ([Id] ASC)
);

