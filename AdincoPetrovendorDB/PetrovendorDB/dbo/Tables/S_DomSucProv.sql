CREATE TABLE [dbo].[S_DomSucProv] (
    [IdDomSucProv] INT           IDENTITY (1, 1) NOT NULL,
    [Ciudad]       NVARCHAR (50) NULL,
    [Calle]        NVARCHAR (50) NULL,
    [Colonia]      NVARCHAR (50) NULL,
    [Numero]       NVARCHAR (8)  NULL,
    [CP]           NVARCHAR (8)  NULL,
    [NumTel]       NVARCHAR (20) NULL,
    [IdProveedor]  INT           NULL,
    [IsEliminado]  BIT           NULL,
    CONSTRAINT [PK_S_DomicilioSucursalesProveedor] PRIMARY KEY CLUSTERED ([IdDomSucProv] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_DomSucP__IdPro__3F9B6DFF] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

