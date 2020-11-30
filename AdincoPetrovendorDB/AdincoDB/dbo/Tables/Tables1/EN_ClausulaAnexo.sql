CREATE TABLE [dbo].[EN_ClausulaAnexo] (
    [IdClausulaAnexo] INT            IDENTITY (1, 1) NOT NULL,
    [ClausulaAnexo]   NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    CONSTRAINT [PK_Cat_General_ClausulaAnexo] PRIMARY KEY CLUSTERED ([IdClausulaAnexo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

