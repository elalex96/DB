CREATE TABLE [dbo].[OT_ProgramaSemanaCerrada] (
    [IdOTSolicitud]  INT           NOT NULL,
    [SemanaID]       VARCHAR (21)  NOT NULL,
    [FechaSemanaIni] DATETIME      NOT NULL,
    [FechaSemanaFin] DATETIME      NOT NULL,
    [CreadoPor]      VARCHAR (50)  NOT NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    [isActivo]       BIT           NULL,
    [ModificadoPor]  VARCHAR (50)  NULL,
    [ModificadoEl]   DATETIME      NULL,
    [MotivoApertura] VARCHAR (250) NULL,
    CONSTRAINT [PK_OT_ProgramaSemanaCerrada] PRIMARY KEY CLUSTERED ([IdOTSolicitud] ASC, [SemanaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProgramaSemanaCerrada_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

