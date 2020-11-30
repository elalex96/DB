CREATE TABLE [dbo].[DEA_Relacion_PR_PO] (
    [ID_R_PR_PO]        INT            IDENTITY (1000, 1) NOT NULL,
    [PO]                NVARCHAR (MAX) NULL,
    [FechaAltaRelacion] DATETIME       NULL,
    [FechaModRelacion]  DATETIME       NULL,
    [CreadoPor]         INT            NULL,
    [ModPor]            INT            NULL,
    [Activo]            BIT            NULL,
    [IsEliminado]       BIT            NULL,
    [EliminadoPor]      INT            NULL,
    [EliminadoEl]       DATETIME       NULL,
    [IdPedido]          INT            NULL,
    [IdCreadoProveedor] INT            NULL,
    [IdAdjuntoPO]       INT            NULL,
    CONSTRAINT [PK_DEA_Relacion_PR_PO] PRIMARY KEY CLUSTERED ([ID_R_PR_PO] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

