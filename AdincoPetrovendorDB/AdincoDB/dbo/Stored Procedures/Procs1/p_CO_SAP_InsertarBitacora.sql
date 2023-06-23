CREATE proc [dbo].[p_CO_SAP_InsertarBitacora]
    @pIdContrato int,
    @pCreadoPor int,
    @AplicacionEjecuto varchar(2000) = '',
    @pId int out
as
select @pId = isnull(max(Id), 0) + 1
from [CO_SAP_ImportBitacora]


insert into [dbo].[CO_SAP_ImportBitacora]
(
    Id,
    IdContrato,
    Inicio,
    Fin,
    TieneError,
    IdNotificacion,
    CreadoEl,
    CreadoPor,
    AplicacionEjecuto
)
select @pId,
       @pIdContrato,
       getdate(),
       NULL,
       0,
       null,
       getdate(),
       @pCreadoPor,
       @AplicacionEjecuto
