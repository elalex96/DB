CREATE TABLE [dbo].[AP_Cita] (
    [CitaID]           INT            IDENTITY (1, 1) NOT NULL,
    [Tipo]             INT            NULL,
    [FechaInicio]      SMALLDATETIME  NULL,
    [FechaFin]         SMALLDATETIME  NULL,
    [TodoElDia]        BIT            NULL,
    [Asunto]           NVARCHAR (50)  NULL,
    [Ubicacion]        NVARCHAR (50)  NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [Estatus]          INT            NULL,
    [Label]            INT            NULL,
    [RecursoID]        INT            NULL,
    [RecursoIDs]       NVARCHAR (MAX) NULL,
    [RecordatorioInfo] NVARCHAR (MAX) NULL,
    [ReaparicionInfo]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Appointments] PRIMARY KEY CLUSTERED ([CitaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

