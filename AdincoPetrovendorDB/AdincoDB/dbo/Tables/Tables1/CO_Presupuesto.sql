CREATE TABLE [dbo].[CO_Presupuesto] (
    [IdPresupuesto]       INT            IDENTITY (10000, 1) NOT NULL,
    [IdAnioContractual]   INT            NOT NULL,
    [IdProgramaActividad] INT            NULL,
    [Version]             INT            NOT NULL,
    [Nombre]              NVARCHAR (MAX) NULL,
    [Comentario]          NVARCHAR (MAX) NULL,
    [FechaAprobacionPEP]  DATE           NULL,
    [CreadoPor]           INT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [ModificadoPor]       INT            NULL,
    [ModificadoEl]        DATETIME       NULL,
    [Activo]              BIT            NULL,
    [IdPresupuestoCNH]    NVARCHAR (50)  NULL,
    [Actual]              BIT            NULL,
    [CIEP]                BIT            NULL,
    [ActivoProcura]       BIT            NULL,
    [InicioPresupuesto]   DATE           NULL,
    [FinPresupuesto]      DATE           NULL,
    CONSTRAINT [PK_Presupuestos] PRIMARY KEY CLUSTERED ([IdPresupuesto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_Presupuesto_CO_ProgramaActividad] FOREIGN KEY ([IdProgramaActividad]) REFERENCES [dbo].[CO_ProgramaActividad] ([IdProgramaActividad]),
    CONSTRAINT [FK_Presupuestos_AniosContractuales] FOREIGN KEY ([IdAnioContractual]) REFERENCES [dbo].[CO_AnioContractual] ([IdAnioContractual])
);

