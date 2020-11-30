CREATE TABLE [dbo].[AX_Bitacora] (
    [IdBitacora]    INT            IDENTITY (1, 1) NOT NULL,
    [DataAreaId]    NVARCHAR (500) NULL,
    [FechaAcceso]   DATETIME       NULL,
    [FechaSalida]   DATETIME       NULL,
    [Error]         INT            NULL,
    [Observacion]   NVARCHAR (MAX) NULL,
    [IdComparativa] NVARCHAR (500) NULL,
    [IpAddress]     NVARCHAR (MAX) NULL,
    [HostName]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AX_Bitacora] PRIMARY KEY CLUSTERED ([IdBitacora] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

