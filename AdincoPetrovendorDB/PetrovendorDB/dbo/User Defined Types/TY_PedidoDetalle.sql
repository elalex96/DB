USE Petrovendor


/****** Object:  UserDefinedTableType [dbo].[ConceptosCNCompraDirecta]    Script Date: 25/03/2022 08:58:35 a. m. ******/
CREATE TYPE [dbo].[TY_PedidoDetalle] AS TABLE(
	[IdSolicitudPedidoDetalle] [int] NOT NULL,
	[Cantidad] FLOAT NOT NULL,
	[CantidadSolicitar]  float not NULL
)
GO
