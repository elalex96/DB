CREATE TABLE [dbo].[CO_DirectorContrato] (
    [idDirectorContrato] INT            IDENTITY (10000, 1) NOT NULL,
    [idDirector]         INT            NULL,
    [idContrato]         INT            NULL,
    [idRegion]           INT            NULL,
    [razonSocial]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK__CO_Direc__B1376A37DA48A06D] PRIMARY KEY CLUSTERED ([idDirectorContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__CO_Direct__idCon__0BF40ECC] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK__CO_Direct__idReg__0CE83305] FOREIGN KEY ([idRegion]) REFERENCES [dbo].[CO_Region] ([IdRegion]),
    CONSTRAINT [FK__CO_Direct__razon__0AFFEA93] FOREIGN KEY ([idDirector]) REFERENCES [dbo].[CO_DirectorOperaciones] ([idDirector])
);

