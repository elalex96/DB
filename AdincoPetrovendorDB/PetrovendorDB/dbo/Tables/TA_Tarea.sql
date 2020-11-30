CREATE TABLE [dbo].[TA_Tarea] (
    [IdTarea]               INT            IDENTITY (1, 1) NOT NULL,
    [NombreTarea]           NVARCHAR (MAX) NULL,
    [IdAprobador]           INT            NULL,
    [IdEstatus]             INT            NULL,
    [Visto]                 BIT            NULL,
    [Comentario]            NVARCHAR (MAX) NULL,
    [Descripcion]           NVARCHAR (MAX) NULL,
    [FechaRegistro]         DATETIME       NULL,
    [FechaCambioEstatus]    DATETIME       NULL,
    [IdPrioridad]           INT            NULL,
    [Activo]                BIT            NULL,
    [IdVencimiento]         INT            NULL,
    [NoSecuencia]           INT            NULL,
    [IdOperacion]           INT            NULL,
    [IdFirma]               NVARCHAR (35)  NULL,
    [IdEstatusEliminado]    INT            NULL,
    [IdEliminado]           INT            NULL,
    [ModificadoPor]         INT            NULL,
    [ModificadoEl]          DATETIME       NULL,
    [EliminadoPor]          INT            NULL,
    [EliminadoEl]           DATETIME       NULL,
    [AsignadoPor]           INT            NULL,
    [MensajeAsignacion]     NVARCHAR (MAX) NULL,
    [FechaActivacionSerial] DATETIME       NULL,
    [UpdateByApp]           BIT            NULL,
    CONSTRAINT [PK_TA_Tarea] PRIMARY KEY CLUSTERED ([IdTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [TA_TareaEstatusOper, sysname,>]
    ON [dbo].[TA_Tarea]([IdEstatus] ASC, [IdOperacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idxIdOperacion_TA_Tarea]
    ON [dbo].[TA_Tarea]([IdOperacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [TA_Tarea_Id_Activo]
    ON [dbo].[TA_Tarea]([Activo] ASC)
    INCLUDE([IdOperacion]) WITH (STATISTICS_NORECOMPUTE = ON);

