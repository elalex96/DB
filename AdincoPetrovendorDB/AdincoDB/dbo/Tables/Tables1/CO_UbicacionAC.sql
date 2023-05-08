CREATE TABLE [dbo].[CO_UbicacionAC] (
    [IdUbicacionAC]   INT            IDENTITY (10000, 1) NOT NULL,
    [NombreUbicacion] NVARCHAR (MAX) NULL,
    [CreadoPor]       INT            NULL,
    CONSTRAINT [PK_UbicacionAC] PRIMARY KEY CLUSTERED ([IdUbicacionAC] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

