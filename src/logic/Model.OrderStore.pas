unit Model.OrderStore;

interface

uses
    System.SysUtils,
    System.Variants,
    Spring,
    Spring.Collections,
    Data.DB,
    {}
    DataModule.Main,
    Model.Order,
    Model.Interfaces;

type
    TOrderStore = class(TInterfacedObject,
                        IOrdersStore)
    private
        fOrders: IList<TOrder>;
    public
        constructor Create;
        procedure Init(aDataModuleMain: TDataModuleMain);
        function GetOrders(): IList<TOrder>;
    end;

implementation


constructor TOrderStore.Create;
begin
    fOrders := TCollections.CreateObjectList<TOrder>(True);
end;


procedure TOrderStore.Init(aDataModuleMain: TDataModuleMain);
var
    aDataSet: TDataSet;
    aOrder: TOrder;
    aAddDate: integer;
begin
    fOrders.Clear();
    aAddDate := Round(Int(Now) - EncodeDate(1998, 05, 06)) - 1;
    aDataSet := aDataModuleMain.fdqOrders;
    aDataSet.Open;
    try
        aDataSet.First;
        while not aDataSet.Eof do
        begin
            aOrder := TOrder.Create;
            fOrders.Add(aOrder);
            aOrder.OrderID := aDataSet.FieldByName('OrderID').AsString;
            aOrder.CompanyId := aDataSet.FieldByName('CustomerID').AsString;
            // aDataSet.FieldByName('EmployeeID').AsInteger;
            aOrder.SaleDate := aDataSet.FieldByName('OrderDate').AsDateTime + aAddDate;
            if not aDataSet.FieldByName('RequiredDate').IsNull then
                aOrder.RequiredDate :=
                    TDateTime(aDataSet.FieldByName('RequiredDate').AsDateTime + aAddDate);
            if not aDataSet.FieldByName('ShippedDate').IsNull then
                aOrder.ShipDate := TDateTime(aDataSet.FieldByName('ShippedDate')
                    .AsDateTime + aAddDate);
            aDataSet.Next();
        end;
    finally
        aDataSet.Close();
    end;
end;


function TOrderStore.GetOrders: IList<TOrder>;
begin
    Result := fOrders;
end;

end.
