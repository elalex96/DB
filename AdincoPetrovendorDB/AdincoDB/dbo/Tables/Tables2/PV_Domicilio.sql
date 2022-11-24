CREATE TABLE [dbo].[PV_Domicilio] (
    [DomilioID]       INT           NOT NULL,
    [EmpresaID]       INT           NOT NULL,
    [Calle]           VARCHAR (MAX) NOT NULL,
    [Interior]        VARCHAR (MAX) NOT NULL,
    [Exterior]        VARCHAR (MAX) NOT NULL,
    [Delegacion]      VARCHAR (MAX) NOT NULL,
    [EstadoID]        INT           NOT NULL,
    [PaisID]          INT           NOT NULL,
    [CP]              VARCHAR (MAX) NOT NULL,
    [Colonia]         VARCHAR (MAX) NOT NULL,
    [IsActual]        BIT           NOT NULL,
    [IsEliminado]     BIT           NOT NULL,
    [TipoDomicilioID] INT           NOT NULL,
    CONSTRAINT [PK_Domicilio] PRIMARY KEY CLUSTERED ([DomilioID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Domicilio_Empresa] FOREIGN KEY ([EmpresaID]) REFERENCES [dbo].[PV_Subcontratista] ([IdSubcontratista]),
    CONSTRAINT [FK_Domicilio_EstadoRepublica] FOREIGN KEY ([EstadoID]) REFERENCES [dbo].[PV_EstadoRepublica] ([idEstado]),
    CONSTRAINT [FK_Domicilio_PaisRepublica] FOREIGN KEY ([PaisID]) REFERENCES [dbo].[PV_PaisRepublica] ([id]),
    CONSTRAINT [FK_Domicilio_TipoDomicilio] FOREIGN KEY ([TipoDomicilioID]) REFERENCES [dbo].[PV_TipoDomicilio] ([TipoDomicilioID])
);

