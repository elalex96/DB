CREATE TABLE [dbo].[CO_ActivoCNH] (
    [IdActivo]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreActivo] NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    CONSTRAINT [PK_Activos] PRIMARY KEY CLUSTERED ([IdActivo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

