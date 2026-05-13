CREATE TABLE [dbo].[JG_Requisiciones] (
    [No# Requisición]          FLOAT (53)     NULL,
    [Contrato]                 NVARCHAR (255) NULL,
    [Periodo]                  NVARCHAR (255) NULL,
    [Plan]                     NVARCHAR (255) NULL,
    [SubTarea]                 NVARCHAR (255) NULL,
    [MesAnterior]              NVARCHAR (255) NULL,
    [NuevoPeriodo]             NVARCHAR (255) NULL,
    [NuevoPlan]                NVARCHAR (255) NULL,
    [NuevaCveSubtarea]         NVARCHAR (255) NULL,
    [NuevaSubTarea]            NVARCHAR (255) NULL,
    [NuevoMes]                 NVARCHAR (255) NULL,
    [NumeroMes]                NVARCHAR (50)  NULL,
    [NumerAno]                 NVARCHAR (50)  NULL,
    [IdContrato]               INT            NULL,
    [IdPresupuestoANT]         INT            NULL,
    [IdPresupuestoNVO]         INT            NULL,
    [IdServicioNVO]            INT            NULL,
    [IDTAREANVA]               INT            NULL,
    [IdLineaPresupuestoMesNVA] INT            NULL
);

