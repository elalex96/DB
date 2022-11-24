CREATE TABLE [dbo].[TA_EstadoFlujoTarea] (
    [Idestado]            INT            IDENTITY (1, 1) NOT NULL,
    [NombreEstado]        NVARCHAR (200) NULL,
    [Descripcion]         NVARCHAR (MAX) NULL,
    [EstadosSubsecuentes] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Ta_EstadosAprobacionSerial] PRIMARY KEY CLUSTERED ([Idestado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

