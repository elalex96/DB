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
	Procesado bit,
	CreadoEl datetime,
	ProcesadoEl datetime
)
