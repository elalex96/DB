CREATE TABLE [dbo].[CO_CONTRATOSJAGUAR] (
    [ID]          INT            IDENTITY (1000, 1) NOT NULL,
    [IdOperadora] INT            NULL,
    [IdContrato]  INT            NULL,
    [RFC]         NVARCHAR (100) NULL,
    [Activo]      BIT            NULL,
    CONSTRAINT [PK_CO_CONTRATOSJAGUAR] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

