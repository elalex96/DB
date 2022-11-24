CREATE procedure [dbo].[SP_IndicadorFlujoTarea](@IdProveedor int )
as
begin
select count(*)as 'Flujos de Tarea' from [TA_FlujoTarea]
where [IdProveedor]=@IdProveedor;
end
