CREATE TABLE [dbo].[PV_Banco] (
    [BancoID]     INT            IDENTITY (1, 1) NOT NULL,
    [Banco]       VARCHAR (MAX)  NOT NULL,
    [Clave]       VARCHAR (10)   NULL,
    [RazonSocial] NVARCHAR (MAX) NULL,
    [Nacional]    BIT            NULL,
    CONSTRAINT [PK_Cat_Banco] PRIMARY KEY CLUSTERED ([BancoID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

