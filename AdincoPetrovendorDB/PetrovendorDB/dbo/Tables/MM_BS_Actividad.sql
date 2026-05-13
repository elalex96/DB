CREATE TABLE [dbo].[MM_BS_Actividad] (
    [IdActividad] INT            NOT NULL,
    [Nombre]      NVARCHAR (300) NULL,
    [Codigo]      NVARCHAR (100) NULL,
    [Activo]      BIT            NULL,
    [IdGrupo]     INT            NULL,
    PRIMARY KEY CLUSTERED ([IdActividad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

