CREATE TABLE [dbo].[TA_Tarea] (
    [IdTarea]            INT            IDENTITY (1, 1) NOT NULL,
    [NombreTarea]        NVARCHAR (MAX) NULL,
    [IdAprobador]        INT            NULL,
    [IdEstatus]          INT            NULL,
    [Visto]              BIT            NULL,
    [Comentario]         NVARCHAR (MAX) NULL,
    [Descripcion]        NVARCHAR (MAX) NULL,
    [FechaRegistro]      DATETIME       NULL,
    [FechaCambioEstatus] DATETIME       NULL,
    [IdPrioridad]        INT            NULL,
    [Activo]             BIT            NULL,
    [IdVencimiento]      INT            NULL,
    [NoSecuencia]        INT            NULL,
    CONSTRAINT [PK_TA_Tarea] PRIMARY KEY CLUSTERED ([IdTarea] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

