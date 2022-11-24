CREATE TABLE [dbo].[EN_IncisoContrato] (
    [IdInciso]  INT            IDENTITY (1, 1) NOT NULL,
    [Inciso]    NVARCHAR (MAX) NULL,
    [CreadoPor] INT            NULL,
    CONSTRAINT [PK_Cat_General_Inciso] PRIMARY KEY CLUSTERED ([IdInciso] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

