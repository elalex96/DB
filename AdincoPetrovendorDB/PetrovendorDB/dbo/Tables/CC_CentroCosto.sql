CREATE TABLE [dbo].[CC_CentroCosto] (
    [IdCentroCosto] INT            IDENTITY (1, 1) NOT NULL,
    [CentroCosto]   NVARCHAR (300) NULL,
    [IdProveedor]   INT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [IsActivo]      BIT            NULL,
    [Numero]        VARCHAR (MAX)  NULL,
    CONSTRAINT [PK_CC_CentroCosto] PRIMARY KEY CLUSTERED ([IdCentroCosto] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_CC_CentroCosto]
    ON [dbo].[CC_CentroCosto]([IdCentroCosto] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

