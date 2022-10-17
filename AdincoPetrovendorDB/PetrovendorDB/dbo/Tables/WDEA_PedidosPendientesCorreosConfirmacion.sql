USE petrovendor
GO
DROP TABLE IF EXISTS WDEA_PedidosPendientesCorreosConfirmacion
GO
CREATE TABLE WDEA_PedidosPendientesCorreosConfirmacion
(
	Id int primary key not null identity(1,1),
	IdSolicitudPedido int,
	IdOperacion int,
	IdAprobador int,
	Purchasing_Document varchar(300),
	IdTarea int,
	IdPedidoActual int,
	IdPedidoGeneral int,
	Procesado bit,
	CreadoEl datetime,
	ProcesadoEl datetime
)
